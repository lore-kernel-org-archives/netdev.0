From: Paul Moore <paul@paul-moore.com>
Subject: Re: [Fix kernel crash in cipso_v4_sock_delattr ]
Date: Mon, 30 Mar 2015 07:32:23 -0400
Message-ID: <129817526.SFnNKPuWia@sifl>
References: <1603159082.92241427713739372.JavaMail.weblogic@epmlwas01c>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Vaneet Narang <v.narang@samsung.com>,
	AJEET YADAV <ajeet.y@samsung.com>
To: maninder1.s@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1603159082.92241427713739372.JavaMail.weblogic@epmlwas01c>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, March 30, 2015 11:09:00 AM Maninder Singh wrote:
> Dear All,
> we found One Kernel Crash issue in cipso_v4_sock_delattr :-
> As Cipso supports only inet sockets so cipso_v4_sock_delattr will crash when
> try to access any other socket type.  cipso_v4_sock_delattr access
> sk_inet->inet_opt which may contain not NULL but invalid address. we found
> this issue with netlink socket.(reproducible by trinity using sendto system
> call .) 

Hello,

First, please go read the Documentation/SubmittingPatches from the kernel 
sources; your patch needs to be resubmitted and the instructions in that file 
will show you how to do it correctly next time.

Second, this appears to only affect Smack based systems, yes?  SELinux based 
systems should have the proper checking in place to prevent this (the checks 
are handled in the LSM).  That said, it probably wouldn't hurt to add the 
extra checking to netlbl_sock_delattr().  If you properly resubmit your patch 
I'll ACK it.

-Paul

-- 
paul moore
www.paul-moore.com
