From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
 ipi_ifindex = 0
Date: Tue, 04 Aug 2009 11:57:01 -0700 (PDT)
Message-ID: <20090804.115701.250978139.davem@davemloft.net>
References: <1248912621.13447.12.camel@merlyn>
	<20090803.212323.256579233.davem@davemloft.net>
	<6c039e090908040036j38666152y2db1d4c55529eaff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: john.dykstra1@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: chiachi@android.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933321AbZHDS4y@vger.kernel.org>
In-Reply-To: <6c039e090908040036j38666152y2db1d4c55529eaff@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chia-chi Yeh (葉家齊) <chiachi@android.com>
Date: Tue, 4 Aug 2009 15:36:46 +0800

> After thinking more deeply, I believe that IPv6 does the right thing
> and IPv4 does not. SO_BINDTODEVICE requires CAP_NET_RAW, so it is a
> privileged operation. Therefore, it looks weird to me if one can
> specify other interface than the bound one without the same
> capability. The following patch makes the behavior in IPv4 and IPv6
> identical. Thanks for your help.

I think we really cannot change behavior here.  If the user specifies
"0" in ipi_ifindex we must respect that in ipc->oif.  This is an
override, and the ability to override is the very purpose of this
control message.

Even GLIBC makes use of that case of specifying "0" in ipi_ifindex.
We must respect it.

I'm not applying any of these patches, sorry.
