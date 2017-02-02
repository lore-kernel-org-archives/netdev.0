From: "Grandhi, Sainath" <sainath.grandhi@intel.com>
Subject: RE: [PATCHv3 5/7] tap: Extending tap device create/destroy APIs
Date: Thu, 2 Feb 2017 23:22:48 +0000
Message-ID: <2C5142675EC1274EAB6230F72F8DC95F28CAC487@ORSMSX113.amr.corp.intel.com>
References: <1485803522-16564-1-git-send-email-sainath.grandhi@intel.com>
        <1485803522-16564-6-git-send-email-sainath.grandhi@intel.com>
 <20170131.125112.287960842388784953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mahesh@bandewar.net" <mahesh@bandewar.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131.125112.287960842388784953.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, January 31, 2017 9:51 AM
> To: Grandhi, Sainath <sainath.grandhi@intel.com>
> Cc: netdev@vger.kernel.org; mahesh@bandewar.net; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCHv3 5/7] tap: Extending tap device create/destroy APIs
> 
> From: Sainath Grandhi <sainath.grandhi@intel.com>
> Date: Mon, 30 Jan 2017 11:12:00 -0800
> 
> > +	list_for_each_entry_safe(tap_major, tmp, &major_list, next) {
> > +		if (tap_major->major == major) {
> > +			return tap_major;
> > +		}
> > +	}
> 
> Single line basic blocks, such as this 'if' statement, should not be surrounded
> by curly braces.
> 
> Also I see not mutual exclusion being implemented to protect this list.  If there
> is, it is not obvious, so it should be documented with a comment explaining
> what protects the list.
Ok. It's my fault to not include safe reading of the list.
I would use the RCU API for list traversal, adding and deleting entries.
Please look for it in my next version.

> 
> > @@ -1175,14 +1228,7 @@ int tap_create_cdev(struct cdev *tap_cdev,
> >  	if (err)
> >  		goto out2;
> >
> > -	macvtap_major.major = MAJOR(*tap_major);
> > -
> > -	idr_init(&macvtap_major.minor_idr);
> > -	mutex_init(&macvtap_major.minor_lock);
> > -
> > -	macvtap_major.device_name = device_name;
> > -
> > -	return err;
> > +	return tap_list_add(*tap_major, device_name);
> >
> >  out2:
> >  	unregister_chrdev_region(*tap_major, TAP_NUM_DEVS);
> 
> If tap_list_add() fails, you will leave the chrdev region registered.
Thanks. Would take care of it.
