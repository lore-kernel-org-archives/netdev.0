From: Andrei Warkentin <awarkentin@vmware.com>
Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.
Date: Thu, 1 Mar 2012 15:41:48 -0800 (PST)
Message-ID: <1659130373.1834747.1330645308581.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
References: <4F4FF712.2030400@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrei Warkentin <andreiw@vmware.com>,
	Andrei Warkentin <andrey.warkentin@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>, kgdb-bugreport@lists.sourceforge.net
To: Jason Wessel <jason.wessel@windriver.com>
Return-path: <kgdb-bugreport-bounces@lists.sourceforge.net>
In-Reply-To: <4F4FF712.2030400@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kgdb-bugreport>
List-Post: <mailto:kgdb-bugreport@lists.sourceforge.net>
List-Help: <mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kgdb-bugreport>,
	<mailto:kgdb-bugreport-request@lists.sourceforge.net?subject=subscribe>
Errors-To: kgdb-bugreport-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

----- Original Message -----
> From: "Jason Wessel" <jason.wessel@windriver.com>
> To: "Andrei Warkentin" <awarkentin@vmware.com>
> Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "Andrei Warkentin" <andreiw@vmware.com>,
> kgdb-bugreport@lists.sourceforge.net, "Matt Mackall" <mpm@selenic.com>, "Andrei Warkentin"
> <andrey.warkentin@gmail.com>
> Sent: Thursday, March 1, 2012 5:24:18 PM
> Subject: Re: [PATCHv3 1/3] NETPOLL: Extend rx_hook support.

> > I did have a question, because it seems you were using qemu / kvm.
>   I have a number of test cases that use kvm, but the netkkgdb does
> not seem to work with the nc.  My question is how am I supposed to
> actually use the netkgdb?
> 
> Here is what I observe on the target system:
> 
> insmod netkgdb.ko netkgdb=@/,@10.0.2.2/
> echo g > /proc/sysrq-trigger
> 
> On my host system:
> nc.traditional -l -u -p 7777
> 
> I will type help, and then the netkgdb is toast.  It doesn't seem to
> respond anymore.
> 

Strange. I've just repeated your steps (I didn't build as a ko before, but now I did)
and I don't see this problem. Can you tell me your qemu/kvm command line?

With qemu I've see odd behavior with ne2k_pci, which is the default
(qemu would wedge) occasionally. If you are using ne2000, can you try rtl8139?
Note: I just tried ne2k_pci, and other than having to specify a local 
IP address (something I don't need to for rtl8139). I've also realized
that if you insert netkgdb as a module without any parameters, it
doesn't bind to existing netdevs - that's a bug.

Anything I should know about your network topology?

Can you also apply the multi-I/O-backend patch and boot with kgdboc=kbd, and
see if the VM is toast after you type "help".

A

------------------------------------------------------------------------------
Virtualization & Cloud Management Using Capacity Planning
Cloud computing makes use of virtualization - but cloud computing 
also focuses on allowing computing to be delivered as a service.
http://www.accelacomm.com/jaw/sfnl/114/51521223/
