From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter spurious ELOOP
Date: Wed, 25 Mar 2009 19:12:45 +0100
Message-ID: <49CA741D.3080705@trash.net>
References: <200903242302.n2ON25u4024288@givry.fdupont.fr> <20090324.162808.114465835.davem@davemloft.net> <49CA64D8.9040602@trash.net> <20090325173742.3C509E601C@farside.isc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Francis.Dupont@fdupont.fr,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Francis Dupont <Francis_Dupont@isc.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762081AbZCYSNQ@vger.kernel.org>
In-Reply-To: <20090325173742.3C509E601C@farside.isc.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francis Dupont wrote:
>> Just to clarify: does the problem happens when you have the MARK rule
>> above in a user-defined chain that has more then one jump leading to
>> it or does it also happen in other cases?
> 
> => I triggered the bug with a real world example:
>  - first add a rule with a MARK target using a set mark with the first/sign
>   bit set to one. This target is coded with this mark put at the same
>   place than the verdict field of standard targets. (note this should
>   be triggered by a lot of targets but I got it with MARK)
>  - try to add another rule (with -A or -I but this works too with restore,
>   the idea is to get a replace ioctl with an illegal value in a verdict
>   position).
>  - if you are (un?)lucky you get the ELOOP error.
>
> PS: I really need a bug-ticket-etc number because some business is implied

I'm not a service center, sorry :) Feel free to create an entry in
the netfilter bugzilla, I'll mark it resolved once the patch is
upstream.

> PPS: here I've cut & paste the config I used to track the bug:#
> ....
> :MARKOUT1 - [0:0]
> -A PREROUTING -d 10.0.200.2/32 -p tcp -m tcp --dport 5001 -j MARKOUT1 
> -A MARKOUT1 -j MARK --set-xmark 0x80000001/0xffffffff 
> -A MARKOUT1 -j CONNMARK --save-mark --nfmask 0x3fffffff --ctmask 0x3fffffff 
> -A MARKOUT1 -j ACCEPT 
> 
> I got the bug with the UDP counterpart:
> 
> iptables -t mangle -A PREROUTING -d 10.0.200.2/32 -p udp --dport 5001 \
> -j MARKOUT1

Thanks, that answers my question. I'll apply your patch and send it to
-stable once its in the mainline kernel.
