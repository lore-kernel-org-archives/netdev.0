From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 16:00:25 +0100
Message-ID: <4BC48709.7060600@gmail.com>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>				 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>				 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>				 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>				 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>				 <1271085862.16881.38.camel@edumazet-laptop> <4BC3461D.3070002@gmail.com>			 <1271091581.16881.41.camel@edumazet-laptop> <4BC44167.4080807@gmail.com>		 <1271155766.16881.245.camel@edumazet-laptop> <4BC44EC8.1010104@gmail.com>	 <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>	 <4BC47F38.5040509@gmail.com> <1271169741.16881.437.camel@edumazet-laptop> <4BC48460.4040001@gma
 il.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep14-int.chello.at ([62.179.121.34]:9715 "EHLO
	viefep14-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab0DMPAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 11:00:37 -0400
In-Reply-To: <4BC48460.4040001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stephen mulcahy wrote:
>> Now some brave fouls to check the 6410 lines of this driver ? ;)
>>
>> Question of the day : Why TSO is broken in forcedeth ?
>> Is it generically broken or is it broken for specific NICS ?
>>
> 
> Actually, it is only when tx-checksumming is turned off that the problem 
>  doesn't occur (so I'm not sure TSO is the problem).
> 
> Additionally, a google also turns up this existing Debian bug 
> http://bugs.debian.org/506419 which seems to be related.

As mentioned in the original Debian bug - I can reproduce this by 
running Hadoop[1] TeraSort[2] but I haven't identified a simpler 
reproducer. I tried to recreate this with iperf and ping -f but neither 
helped - it may be that the problem only occurs when systems are passing 
large amounts of traffic and have very high cpu utilisation (when 
running the Hadoop TeraSort all 8 cores run at 70-100% utilisation as 
measure with htop - I plan to instrument the nodes with something like 
Zabbix or Ganglia but it hasn't happened yet).

-stephen

[1] http://hadoop.apache.org/
[2] 
http://hadoop.apache.org/common/docs/current/api/org/apache/hadoop/examples/terasort/package-summary.html
