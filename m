From: "Alex Aizman" <itn780@yahoo.com>
Subject: RE: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Thu, 31 Mar 2005 11:15:46 -0800
Message-ID: <200503311916.j2VJG6RV002517@oss.sgi.com>
References: <20050331114122.GL24804@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <open-iscsi@googlegroups.com>, "'jamal'" <hadi@cyberus.ca>,
        "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        "'Rik van Riel'" <riel@redhat.com>, <mpm@selenic.com>,
        <michaelc@cs.wisc.edu>, <ksummit-2005-discuss@thunk.org>,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Andi Kleen'" <ak@muc.de>
In-Reply-To: <20050331114122.GL24804@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Andi Kleen wrote: 
>
> > It makes sense to provide an API for the NIC driver to allocate skb 
> > from the
> > *right* mempool. This way if I have plenty of hw rings and/or can 
> > allow myself a luxury to associate 1-to-1 connection and 
> ring, there's 
> > a nice and clean memory management model. Even NICs that 
> have only few 
> > rings could use this - for critical (e.g., storage) connections.
> 
> It wont work - I can guarantee you that if you add a limit 
> like "we only support 8 iscsi connections max" then 
> users/customers will raise hell because it does not fit their 
> networks.
> 

Something a bit more intelligent, like: we only support 7 resource-protected
(a.k.a. critical) iSCSI connection, and we use one remaining ring for the
rest iSCSI, TCP, UDP, etc. traffic. The 7 iSCSI connections could be quite a
bit, in terms of LUNs, and just enough for a customer to feel "protected" in
a sense that unrelated receive burst starves storage traffic to death. Note
that "8 rings" here is just an example; as time goes by the number of hw
receive rings and the hw ability to intelligently classify and steer traffic
onto these rings will only increase.  

Alex
