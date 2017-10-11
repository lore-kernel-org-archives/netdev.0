From: Christina Jacob <christina.jacob.koikara@gmail.com>
Subject: Re: [PATCH v2] XDP Program for Ip forward
Date: Wed, 11 Oct 2017 22:36:48 +0530
Message-ID: <CAGSfdShhRGe97-EtgYGFdYhEtGfFPU_OmeCX3UkxkCZ5XGCt4A@mail.gmail.com>
References: <1507620532-25804-1-git-send-email-Christina.Jacob@cavium.com>
 <20171010151231.69fde82f@redhat.com> <20171010160057.32678367@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, Sunil.Goutham@cavium.com,
        daniel@iogearbox.net, David Ahern <dsahern@gmail.com>,
        Christina Jacob <Christina.Jacob@cavium.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010160057.32678367@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 10, 2017 at 7:30 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> On Tue, 10 Oct 2017 15:12:31 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
>
> > I'll try to test/benchmark your program...
>
> In my initial testing, I cannot get this to work...
>

What is the test setup you are using? So that I can also test
I verified the program in this minimal test setup, I did not see any
issue with the mac addresses being set.

Below is the test setup.

machine 1                                             machine 2
(90.0.0.2)port 1 ===============>port3(90.0.0.1)
                                                               ||
(80.0.0.2)port 2<================port4(80.0.0.1)
traffic gen                                             xdp program

Below are the steps followed to run the program.

 Assigned ips in different subnets to interfaces 3 and 4
Ip of port 1 is in the same subnet as port 3
Ip of port 2 is in the same subnet as port 4
sysctl -w net.core.bpf_jit_enable=1
./xdp_router_ipv4 eth0 eth1

Note: The program will not generate arp requests. Proper arp entries
need to be added to get the packets forwarded correctly.

> You do seem to XDP_REDIRECT out the right interface, but you have an
> error with setting the correct MAC address.
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
