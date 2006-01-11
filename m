From: Robin Humble <rjh+e1000@cita.utoronto.ca>
Subject: Re: tso off, tx hang, and codes crashing
Date: Tue, 10 Jan 2006 23:18:44 -0500
Message-ID: <20060111041844.GA19842@lemming.cita.utoronto.ca>
References: <20060110051250.GA19299@lemming.cita.utoronto.ca> <Pine.WNT.4.63.0601100946400.1360@jbrandeb-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.63.0601100946400.1360@jbrandeb-desk.amr.corp.intel.com>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2006 at 10:16:23AM -0800, Jesse Brandeburg wrote:
>On Mon, 9 Jan 2006, Robin Humble wrote:
>>until we turned off tso on our cluster using
>>  ethtool -K eth0 tso off
>>  ethtool -K eth1 tso off
...
>>the major problems only happen for >32 cpu parallel runs. smaller runs
>>work fine. unfortunately we haven't found a simple small MPI code that
>>triggers the tso problems.
>do you know what packet size triggered the problem?  It sounds like the 

unfortunately not really.

>network traffic at the time of failure is lots and lots of outstanding 
>transmits over many concurrent connections, is that correct?

repeatedly typing 'netstat -t' the most traffic I see is something like:

  [root@beer96 ~]# netstat -t | grep -v '  0      0 '
  Active Internet connections (w/o servers)
  Proto Recv-Q Send-Q Local Address      Foreign Address    State
  tcp    21720      0 beer96:57747       beer82:42185       ESTABLISHED
  tcp    37176      0 beer96:57747       beer76:45725       ESTABLISHED
  tcp    37176      0 beer96:38197       beer76:39912       ESTABLISHED
  tcp    37176      0 beer96:57747       beer86:54898       ESTABLISHED
  tcp       24      0 beer96:57747       beer74:57982       ESTABLISHED
  tcp       24      0 beer96:38197       beer74:59163       ESTABLISHED
  tcp    37176      0 beer96:57747       beer86:54883       ESTABLISHED
  tcp       24      0 beer96:57747       beer74:57967       ESTABLISHED
  tcp       24      0 beer96:38197       beer74:59178       ESTABLISHED
  tcp    37176      0 beer96:38197       beer82:34102       ESTABLISHED
  tcp    37176      0 beer96:38197       beer82:34117       ESTABLISHED
  tcp        0  37176 beer96:38197       beer86:48448       ESTABLISHED
  tcp    37176      0 beer96:57747       beer84:54840       ESTABLISHED
  tcp    37176      0 beer96:57747       beer84:54827       ESTABLISHED
  tcp    37176      0 beer96:38197       beer80:42088       ESTABLISHED
  tcp    17376      0 beer96:57747       beer90:55069       ESTABLISHED
  tcp    21720      0 beer96:57747       beer90:55058       ESTABLISHED
  tcp    37176      0 beer96:57747       beer81:57843       ESTABLISHED
  tcp    37176      0 beer96:38197       beer91:51101       ESTABLISHED
  tcp    24792      0 beer96:57747       beer75:44797       ESTABLISHED
  tcp    37176      0 beer96:38197       beer77:54658       ESTABLISHED
  tcp    37176      0 beer96:57747       beer83:46847       ESTABLISHED
  tcp        0  23168 beer96:57747       beer83:46826       ESTABLISHED
  tcp    21248    976 beer96:57747       beer89:48842       ESTABLISHED
  tcp       24      0 beer96:38197       beer75:51657       ESTABLISHED
  tcp       24      0 beer96:57747       beer73:52901       ESTABLISHED
  tcp       24      0 beer96:57747       beer73:52886       ESTABLISHED
  tcp       48      0 beer96:38197       beer73:47969       ESTABLISHED
  [root@beer96 ~]# 

there's about 140 sockets open total, but the rest have no traffic in
them at this instant.

>>we'd like to use tso as it means 5 to 10% less cpu usage for large
>>message sizes (but strangely a few more micro-seconds latency).
>>see attached pic.
>Thats what TSO is supposed to help.  The latency increase can be played 
>with or mitigated by changing tcp_tso_win_divisor in /proc/.../ipv4

cool. thanks.

>>so what's the best way I can help you debug TCP segmentation offload
>>issue?
>we can start with getting some transmit ring dumps at the time of failure. 
>I have code to do this but need to port it to 2.6.15.  i'll try to get 
>that code to you in the next couple of days.

ok. ta.
actually the tx reset only happens occasionally with the 2.6.15 kernel
and 6.3.9 e1000 driver. mostly the code just stops - presumably 'cos a
message got lost. I'll check more if it's at a repeatable place...

cheers,
robin


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
