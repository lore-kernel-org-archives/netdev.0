From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: e1000e disabling already-disabled device
Date: Tue, 5 Mar 2013 02:11:39 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1844D02FD70@ORSMSX102.amr.corp.intel.com>
References: <20130303162124.GA31371@redhat.com>
 <20130303233624.GA28784@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"khlebnikov@openvz.org" <khlebnikov@openvz.org>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63327 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932831Ab3CECLl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 21:11:41 -0500
In-Reply-To: <20130303233624.GA28784@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com]
> Sent: Sunday, March 03, 2013 3:36 PM
> To: Dave Jones
> Cc: netdev@vger.kernel.org; Allan, Bruce W
> Subject: Re: e1000e disabling already-disabled device
> 
> Dave Jones <davej@redhat.com> :
> [...]
> >  ------------[ cut here ]------------
> >  WARNING: at drivers/pci/pci.c:1397 pci_disable_device+0x90/0xa0()
> >  Hardware name: 2356JK8
> >  Device e1000e
> > disabling already-disabled device
> > Modules linked in:
> >  dm_crypt arc4 iwldvm mac80211 ipv6 iTCO_wdt xfs iTCO_vendor_support
> libcrc32c coretemp kvm_intel kvm crc32c_intel ghash_clmulni_intel
> microcode snd_hda_codec_hdmi snd_hda_codec_realtek btusb bluetooth
> iwlwifi pcspkr snd_hda_intel cfg80211 snd_hda_codec snd_pcm lpc_ich
> mfd_core e1000e snd_page_alloc ptp pps_core thinkpad_acpi hwmon
> led_class rfkill wmi nfsd auth_rpcgss nfs_acl lockd sunrpc i915 i2c_algo_bit
> drm_kms_helper drm i2c_core video
> > Pid: 19776, comm: kworker/u:11 Not tainted 3.8.0+ #6
> > Call Trace:
> >  [<ffffffff81049855>] warn_slowpath_common+0x75/0xa0
> >  [<ffffffff81049936>] warn_slowpath_fmt+0x46/0x50
> >  [<ffffffff81359760>] pci_disable_device+0x90/0xa0
> >  [<ffffffffa0251092>] __e1000_shutdown+0x262/0x8a0 [e1000e]
> >  [<ffffffffa0251743>] e1000_suspend+0x23/0x50 [e1000e]
> >  [<ffffffff816284b9>] ? sub_preempt_count+0x79/0xd0
> >  [<ffffffff8135bd97>] pci_pm_suspend+0x77/0x140
> >  [<ffffffff8135bd20>] ? pci_pm_poweroff+0xf0/0xf0
> >  [<ffffffff8140c678>] dpm_run_callback+0x58/0x90
> >  [<ffffffff8140c79d>] __device_suspend+0xed/0x280
> >  [<ffffffff8140d1ef>] async_suspend+0x1f/0xa0
> 
> Could it be that runtime power management is also enabled, you have no
> link and thus end running both runtime_suspend and suspend at different
> times ?
> 
> I wonder why the driver disables the PCI device here btw.
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/intel/e1000e/netdev.c
> index a177b8b..5c643c6 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -5986,8 +5986,6 @@ static int __e1000_shutdown(struct pci_dev
> *pdev, bool *enable_wake,
>  	 */
>  	e1000e_release_hw_control(adapter);
> 
> -	pci_disable_device(pdev);
> -
>  	return 0;
>  }
> 
> ---
> Ueimor

This is a known issue and a patch from Konstantin Khlebnikov <khlebnikov@openvz.org> is currently under test.

Thanks,
Bruce.
