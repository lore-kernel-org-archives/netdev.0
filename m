From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Poor UDP performance using 2.6.21-rc5-rt5
Date: Sun, 01 Apr 2007 13:07:21 -0700
Message-ID: <461010F9.7040706@us.ibm.com>
References: <461004CE.1030009@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Dave Sperry <dave_sperry@ieee.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <461004CE.1030009@ieee.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Sperry wrote:
> Hi

(adding netdev to cc list)

> I have a dual core Opteron machine that exhibits poor UDP performance 
> (RT consumes more than 2X cpu) with the 2.6.21-rc5-rt5 as compared to 
> 2.6.21-rc5. Top shows the IRQ handler consuming a lot of CPU.

Dave, any chance you've got oprofile working on the -rt5?
And I'm assuming nothing very different in the stats or errors
through both runs?

thanks,
Nivedita

> The mother board is a Supermicro H8DME-2 with one dual core Opteron 
> installed. The networking is provided by the on board nVidia MCP55Pro chip.
> 
> The RT test is done using netperf 2.4.3 with the server on an IBM LS20 
> blade running RHEL4U2 and the Supermicro running netperf under RHEL5 
> with 2.6.21-rc5-rt5.
> The Non-RT test was done on the exact same setup except 2.6.21-rc5-rt5 
> was loaded on the SuperMicro board.
> 
> Cyclesoak was used to measure CPU utilization in all cases.
> 
> 
> 
> Here are the RT results
> ########################################################3
> ## 2.6.21-rc5-rt5
> #######################################################
> $ !netper
> netperf -l 100 -H 192.168.70.11 -t UDP_STREAM -- -m 1025
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
> 192.168.70.11 (192.168.70.11) port 0 AF_INET
> Socket  Message  Elapsed      Messages
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
> 
> 126976    1025   100.00    8676376      0     711.46
> 135168           100.00    8676376            711.46
> 
> ########## cyclesoak during test
> $ ./cyclesoak
> using 2 CPUs
> System load: -0.1%
> System load: 40.5%
> System load: 51.6%
> System load: 51.5%
> System load: 50.9%
> System load: 50.7%
> System load: 50.8%
> System load: 50.7%
> System load: 50.6%
> 
> ######## top during test
> top - 13:26:48 up 8 min,  4 users,  load average: 1.74, 0.46, 0.15
> Tasks: 149 total,   4 running, 145 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.7%us, 16.8%sy, 50.6%ni,  0.0%id,  0.0%wa, 25.6%hi,  6.3%si,  
> 0.0%st
> Mem:   2035444k total,   465888k used,  1569556k free,    28840k buffers
> Swap:  3068372k total,        0k used,  3068372k free,   318668k cached
> 
>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
> 3865 eadi      39  19  6804 1164  108 R  100  0.1   0:38.25 cyclesoak
> 2715 root     -51  -5     0    0    0 S   51  0.0   0:09.52 IRQ-8406
> 3867 eadi      25   0  6440  632  480 R   34  0.0   0:06.03 
> netperf         19 root     -51   0     0    0    0 S   13  0.0   
> 0:02.33 softirq-net-tx/
> 3866 eadi      39  19  6804 1164  108 R    1  0.1   0:20.47 cyclesoak
> 3167 root      25   0 29888 1180  888 S    0  0.1   0:00.93 automount
> 3861 eadi      15   0 12712 1076  788 R    0  0.1   0:00.19 top
>    1 root      18   0 10308  668  552 S    0  0.0   0:00.67 init         
> 2 root      RT   0     0    0    0 S    0  0.0   0:00.00 migration/0   
>    3 root      RT   0     0    0    0 S    0  0.0   0:00.00 posix_cpu_timer
>    4 root     -51   0     0    0    0 S    0  0.0   0:00.00 softirq-high/0
>    5 root     -51   0     0    0    0 S    0  0.0   0:00.00 softirq-timer/0
>    6 root     -51   0     0    0    0 S    0  0.0   0:00.00 softirq-net-tx/
>    7 root     -51   0     0    0    0 S    0  0.0   0:00.00 softirq-net-rx/
>    8 root     -51   0     0    0    0 S    0  0.0   0:00.00 softirq-block/0
> 
> ########################
> The baseline results:
> RHEL5 with 2.6.21-rc5 kernel
> ##############################
> 
> $  netperf -l 100 -H 192.168.70.11 -t UDP_STREAM -- -m 1025
> 
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
> 192.168.70.11 (192.168.70.11) port 0 AF_INET
> Socket  Message  Elapsed      Messages
> Size    Size     Time         Okay Errors   Throughput
> bytes   bytes    secs            #      #   10^6bits/sec
> 
> 126976    1025   100.00    11405485      0     935.24
> 135168           100.00    11405485            935.24
> 
> #######################################
> $ ./cyclesoak
> using 2 CPUs
> System load:  7.6%
> System load: 29.6%
> System load: 29.6%
> System load: 28.9%
> System load: 24.9%
> System load: 25.0%
> System load: 24.8%
> System load: 24.9%
> 
> #######################################
> top:top - 13:52:22 up 10 min,  6 users,  load average: 1.46, 0.43, 0.17
> Tasks: 118 total,   4 running, 114 sleeping,   0 stopped,   0 zombie
> Cpu(s):  0.5%us,  9.8%sy, 75.7%ni,  0.0%id,  0.0%wa,  5.8%hi,  8.1%si,  
> 0.0%st
> Mem:   2057200k total,   459128k used,  1598072k free,    29020k buffers
> Swap:  3068372k total,        0k used,  3068372k free,   318968k cached
> 
>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
> 3882 eadi      39  19  6804 1164  108 R  100  0.1   0:52.11 cyclesoak
> 3881 eadi      39  19  6804 1164  108 R   65  0.1   0:38.47 cyclesoak
> 3883 eadi      15   0  6436  632  480 R   35  0.0   0:18.26 netperf
> 3879 eadi      15   0 12580 1052  788 R    0  0.1   0:00.15 top
>    1 root      18   0 10308  664  552 S    0  0.0   0:00.48 init         
> 2 root      RT   0     0    0    0 S    0  0.0   0:00.00 migration/0
>    3 root      34  19     0    0    0 S    0  0.0   0:00.01 ksoftirqd/0
>    4 root      RT   0     0    0    0 S    0  0.0   0:00.00 watchdog/0
>    5 root      RT   0     0    0    0 S    0  0.0   0:00.00 migration/1
>    6 root      34  19     0    0    0 S    0  0.0   0:00.00 ksoftirqd/1
> 
> Any thoughts on how to fix this?
> 
> Thanks,
> -Dave
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe 
> linux-rt-users" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
