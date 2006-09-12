From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 12 Sep 2006 21:49:52 +0200
Message-ID: <200609122149.52870.mb@bu3sch.de>
References: <20060911235803.GB32752@tuxdriver.com> <20060911235912.GC32752@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:15781
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030288AbWILTvB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 15:51:01 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <20060911235912.GC32752@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 12 September 2006 01:59, John W. Linville wrote:
> +	value16 = bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				     BCM43xx_UCODE_REVISION);
> +
> +	dprintk(KERN_INFO PFX "Microcode rev 0x%x, pl 0x%x "
> +		"(20%.2i-%.2i-%.2i  %.2i:%.2i:%.2i)\n", value16,
> +		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				   BCM43xx_UCODE_PATCHLEVEL),
> +		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				    BCM43xx_UCODE_DATE) >> 12) & 0xf,
> +		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				    BCM43xx_UCODE_DATE) >> 8) & 0xf,
> +		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				   BCM43xx_UCODE_DATE) & 0xff,
> +		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				   BCM43xx_UCODE_TIME) >> 11) & 0x1f,
> +		(bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				   BCM43xx_UCODE_TIME) >> 5) & 0x3f,
> +		bcm43xx_shm_read16(bcm, BCM43xx_SHM_SHARED,
> +				   BCM43xx_UCODE_TIME) & 0x1f);
> +
> +	if ( value16 > 0x128 ) {
> +		dprintk(KERN_ERR PFX
> +			"Firmware: no support for microcode rev > 0x128\n");
> +		err = -1;
> +		goto err_release_fw;
> +	}

Hm, this mustn't be a dprintk, as it's compiled away if
debugging is disabled. So it silently fails.
The text could be clarified, too.
returning -1 as error code is also very bad, as it's
propagated to userspace. I suggest EOPNOTSUPP, but maybe there's
something better.
Larry, can you do a patch which changes it to something like the following?

	if ( value16 > 0x128 ) {
		printk(KERN_ERR PFX
			"Firmware: no support for microcode extracted "
			"from version 4.x binary drivers.\n");
		err = -EOPNOTSUPP;
		goto err_release_fw;
	}

-- 
Greetings Michael.
