From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] au1000_eth.c Power Management, driver registration and
 module support
Date: Wed, 31 May 2006 19:01:02 +0400
Message-ID: <447DAFAE.10503@ru.mvista.com>
References: <20060405154711.GL7029@enneenne.com> <20060405222332.GO7029@enneenne.com> <20060405222620.GP7029@enneenne.com> <4435290C.50607@ru.mvista.com> <20060406155011.GC23424@enneenne.com> <4446857D.90507@ru.mvista.com> <20060502150914.GE20543@gundam.enneenne.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Linux-MIPS <linux-mips@linux-mips.org>,
	Jordan Crouse <jordan.crouse@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:10706 "HELO
	mail.dev.rtsoft.ru") by vger.kernel.org with SMTP id S965053AbWEaPCF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 11:02:05 -0400
To: Rodolfo Giometti <giometti@linux.it>
In-Reply-To: <20060502150914.GE20543@gundam.enneenne.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Rodolfo Giometti wrote:

> here:

>    http://ftp.enneenne.com/pub/misc/au1100-patches/linux/patch-au1000_eth-pm-and-registration

> the new version of my patch for au1000_eth.c who should implement:

> Also, as suggested by Sergei it:
> 
> * uses physical addresses and not KSEG1-based virtual anymore and
>   claims/releases the 4-byte MAC enable registers:
> 
>    wwpc:~# cat /proc/iomem
>    10500000-1050ffff : eth-base
>    10520000-10520003 : eth-mac
>       
> * assigns to the Ethernet ports two consecutive MAC addresses:
> 
>    -		dev->dev_addr[4] += 0x10;
>    +				((unsigned long) macen_addr);
>    +		memcpy(ndev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
>    +		ndev->dev_addr[5] += 0x01;
>       
> Ciao,

    Now that this is merged, Rodolfo's patch should probably preempt mine...
but it looks like something was lost during the transition: I failed to see
where SYS_PINFUNC register is actually read (the comment mentioning this was 
retained :-) to check whether Ethernet port 1 is enabled (its pins are shared 
w/GPIO)...

> Rodolfo

WBR, Sergei

