From: Tim Gardner <tim.gardner@canonical.com>
Subject: Re: [PATCH net-next] net: vxge: Add MODULE_FIRMWARE
Date: Mon, 16 Apr 2012 06:21:53 -0600
Message-ID: <4F8C0EE1.7030901@canonical.com>
References: <1334262882-96973-1-git-send-email-tim.gardner@canonical.com> <1334498215.3209.4.camel@deadeye>
Reply-To: tim.gardner@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Tim Gardner <tim.gardner@canonical.com>,
	linux-kernel@vger.kernel.org, Jon Mason <jdmason@kudzu.us>,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334498215.3209.4.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

On 04/15/2012 07:56 AM, Ben Hutchings wrote:
> On Thu, 2012-04-12 at 14:34 -0600, Tim Gardner wrote:
>> Cc: Jon Mason <jdmason@kudzu.us> Cc: netdev@vger.kernel.org 
>> Signed-off-by: Tim Gardner <tim.gardner@canonical.com> --- 
>> drivers/net/ethernet/neterion/vxge/vxge-main.c |    2 ++ 1 file
>> changed, 2 insertions(+)
>> 
>> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c
>> b/drivers/net/ethernet/neterion/vxge/vxge-main.c index
>> 51387c3..dcef72d 100644 ---
>> a/drivers/net/ethernet/neterion/vxge/vxge-main.c +++
>> b/drivers/net/ethernet/neterion/vxge/vxge-main.c @@ -4856,3
>> +4856,5 @@ vxge_closer(void) } module_init(vxge_starter); 
>> module_exit(vxge_closer); +MODULE_FIRMWARE("vxge/X3fw-pxe.ncf"); 
>> +MODULE_FIRMWARE("vxge/X3fw.ncf");
> 
> I don't agree; these firmware files are updates for the flash and
> only need to be loaded once.
> 
> Also: this driver's behaviour of automatically updating flash
> without any confirmation seems quite dangerous.  The driver also
> isn't usable after it performs such an update:
> 
> printk(KERN_NOTICE "Upgrade of firmware successful!  Adapter must
> be " "hard reset before using, thus requiring a system reboot or a
> " "hotplug event.\n");
> 
> So what is the point of integrating firmware update into the driver
> at all?
> 
> Ben.
> 

I guess I'm confused about use of the MODULE_FIRMWARE() macro. I
thought it merely described the names of the firmware files that were
actually used by the driver and had no run-time impact. Regardless of
whether firmware files are used on every load, why _not_ describe them
to modinfo ?

I'm auditing the Ubuntu linux-firmware package to reduce size by
removing obsolete firmware files. Along the way I'm also trying to
update the drivers that have caught my attention in their use of
MODULE_FIRMWARE.

rtg
- -- 
Tim Gardner tim.gardner@canonical.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJPjA7cAAoJED12yEX6FEfKqWEQAJHHf/g0yuJg5eJ7XSdCJWbV
6xs5NNj3Wwo2bN578PnwK28grBFT6atDg6Y0KkcMgZ/NCc7Q8GN/7yJaK+VcW6wQ
395JNYf67bFx+6B+MDVj2qPHa/2EJjYGjZlxMzPPIKUqYOzHt18A779Tb5DLWelj
B1DAJJcTDVF1jyAEB/4zCDq1R39jARWGDzC11OqrQqEmBqbE2z5CgLeDECR0uDsg
axyIW4Mc+nSF1SrrmvdtXfHzDPN+wpXVoGTjb83iqBLWSkKo8QYQDQLnc67mZgAa
lT+ZdFIfAY8vE/PmfokX+xkCc7Dk1B36fIuwWEIRM4QUgFp0skXHUyr8n3xDRLiD
+Kcb3IMIIprzlPi7zpEwB0ulubyjKdh8+dCwlHZVLmRt/QgXUyLCQJG6vqg6WlBO
T53xZ24JcwmdSASYDMTxWmEc3ERq33b1uKPfrUGTLENdyt4F5yU1KT0HXmkJ8Chq
/wQLX9fAC3janMKJP4fdQvox/WBAihZ4wIBNUKnCYl01XXCDvy0FnOtxk3ZGPHzv
g1tS8U2pJUuktX74U1p4ltrKQXhW3z4Oro5BdLTqNunlXDqmT0kiBVkLbJmDNzwK
mL7tlcx8Nn28WRYUM+MW7J1C0+tVRaVMtF8dW1ICduhzzPy5KSarI23SFlExoQ5s
Kn56ELI/wV/ajx+z2pTk
=mobO
-----END PGP SIGNATURE-----
