From: Andi Kleen <ak@muc.de>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: 31 Mar 2005 21:34:44 +0200
Message-ID: <20050331193444.GS24804@muc.de>
References: <20050331114122.GL24804@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: open-iscsi@googlegroups.com, "'jamal'" <hadi@cyberus.ca>,
        "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        "'Rik van Riel'" <riel@redhat.com>, mpm@selenic.com,
        michaelc@cs.wisc.edu, ksummit-2005-discuss@thunk.org,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Thu, 31 Mar 2005 21:34:44 +0200
To: Alex Aizman <itn780@yahoo.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Something a bit more intelligent, like: we only support 7 resource-protected
> (a.k.a. critical) iSCSI connection, and we use one remaining ring for the
> rest iSCSI, TCP, UDP, etc. traffic. The 7 iSCSI connections could be quite a
> bit, in terms of LUNs, and just enough for a customer to feel "protected" in
> a sense that unrelated receive burst starves storage traffic to death. Note
> that "8 rings" here is just an example; as time goes by the number of hw
> receive rings and the hw ability to intelligently classify and steer traffic
> onto these rings will only increase.  

[assuming you want to solve the oom deadlock 100% which I claim is
not practicable. But lets pretend it would be possible with hardware
classification support:]

This does not work, because any writable file system can be in theory
an OOM deadlock and would need to be resource protected. Just someone needs 
to mmap a file on it and dirty enough pages in it to full up system
memory and make the system deadlock while trying to clean pages
to get free memory.

The only "safe" fs that would work is a read only fs where there cant be
any dirty pages, but that would be a rather hard to sell restriction.

-Andi
