From: jamal <hadi@cyberus.ca>
Subject: Re: Asynchronous crypto layer.
Date: 31 Oct 2004 10:03:50 -0500
Message-ID: <1099235030.1038.192.camel@jzny.localdomain>
References: <1099030958.4944.148.camel@uganda>
	 <1099053738.1024.104.camel@jzny.localdomain>
	 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	 <20041030203550.GB6256@gate.ebshome.net>
	 <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
	 <20041030205630.GD6256@gate.ebshome.net>
	 <20041031012423.74b98698@zanzibar.2ka.mipt.ru>
	 <1099179687.1041.117.camel@jzny.localdomain>
	 <20041031121308.648e98f9@zanzibar.2ka.mipt.ru>  <4184C286.3000400@suse.cz>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com, cryptoapi@lists.logix.cz,
        Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Ludvig <mludvig@suse.cz>
In-Reply-To: <4184C286.3000400@suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-10-31 at 05:46, Michal Ludvig wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1

> Yes, I have *some* numbers, but consider that they are for quite
> eligible setup - encrypting ~1.5k IPsec packets. I should retry with a
> much smaller MTU to see the difference...
> 

You should try with different packet sizes for different hardware, or
s/ware drivers with and without async; with and without batching.
packet sizes 64,256,512,1024,1500 bytes. batch sizes, 1,2,4,8,16,..

> I think it won't be the programmer but the system administrator who will
> have to correctly set priorities and constraints for different
> hardware/software engines for the particular system. 

Why is the admin involved in such decision making?

> With a slow CPU it
> may be worth to offload even small blocks to hardware, with a fast one
> it may be worth to set HW and SW as equal, etc.
> 

I think the system should discover all this at runtime.
If the driver says its busy, you dont give it more work.
Clearly giving it more data is beneficial; hence before it gets busy
you give it enough to overcome the setup cost.
You should have qos (start with simple strict priority); and the
preference could be given to large packets etc as long as you dont
introduce reordering.
Come to think of it, this would be really easily doable if the crypto
device appeared to the system as a netdevice.

cheers,
jamal
