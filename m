From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] netif_rx: receive path optimization
Date: 31 Mar 2005 18:36:47 -0500
Message-ID: <1112312206.1096.25.camel@jzny.localdomain>
References: <20050330132815.605c17d0@dxpl.pdx.osdl.net>
	 <20050331120410.7effa94d@dxpl.pdx.osdl.net>
	 <1112303431.1073.67.camel@jzny.localdomain> <424C6A98.1070509@hp.com>
	 <1112305084.1073.94.camel@jzny.localdomain>  <424C7CDC.8050801@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <424C7CDC.8050801@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-31 at 17:42, Rick Jones wrote:

> I "never" see that because I always bind a NIC to a specific CPU :)  Just about 
> every networking-intensive benchmark report I've seen has done the same.
> 

Do you have to be so clever? ;->

> > Note Linux is quiet resilient to reordering compared to other OSes (as
> > you may know) but avoiding this is a better approach - hence my
> > suggestion to use NAPI when you want to do serious TCP.
> 
> Would the same apply to NIC->CPU interrupt assignments? That is, bind the NIC to 
> a single CPU.
> 

No reordering there.


> > Dont think we can do that unfortunately: We are screwed by the APIC
> > architecture on x86.
> 
> The IPS and TOPS stuff was/is post-NIC-interrupt. Low-level driver processing 
> still happened/s on a specific CPU, it is the higher-level processing which is 
> done on another CPU.  The idea - with TOPS at least, is to try to access the ULP 
> (TCP, UDP etc) structures on the same CPU as last accessed by the app to 
> minimize that cache to cache migration.
> 

But if interupt happens on "wrong" cpu - and you decide higher level
processing is to be done on the "right" cpu (i assume queueing on some
per CPU queue); then isnt that expensive? Perhaps IPIs involved even?

cheers,
jamal
