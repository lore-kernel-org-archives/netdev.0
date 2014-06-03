From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] atm: fore200e.c: Cleaning up uninitialized variables
Date: Mon, 02 Jun 2014 17:11:20 -0700 (PDT)
Message-ID: <20140602.171120.192669833635400682.davem@davemloft.net>
References: <1401577712-4447-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<CAOesGMi4SGRP6_WMgv3xz_QrGScktYGQEK-muCrE=ohFBfeBeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org, chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAOesGMi4SGRP6_WMgv3xz_QrGScktYGQEK-muCrE=ohFBfeBeQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>
Date: Sun, 1 Jun 2014 17:10:39 -0700

> On Sat, May 31, 2014 at 4:08 PM, Rickard Strandqvist
> <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org> wrote:
>> There is a risk that the variable will be used without being initialized.
>>
>> This was largely found by using a static code analysis program called cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
>> ---
>>  drivers/atm/fore200e.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
>> index 204814e..d4725fc 100644
>> --- a/drivers/atm/fore200e.c
>> +++ b/drivers/atm/fore200e.c
>> @@ -2780,7 +2780,7 @@ static struct pci_driver fore200e_pca_driver = {
>>
>>  static int __init fore200e_module_init(void)
>>  {
>> -       int err;
>> +       int err = 0;
>>
>>         printk(FORE200E "FORE Systems 200E-series ATM driver - version " FORE200E_VERSION "\n");
> 
> 
> I can see how a tool that doesn't know about Kconfig dependencies
> might think so, but if you look at Kconfig you'll see that for this
> driver to be enabled for building either CONFIG_SBUS or CONFIG_PCI
> must be set, and if either of them is then this variable will not be
> used without first being set.

Yeah but it's harmless to apply this, which I've done.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
