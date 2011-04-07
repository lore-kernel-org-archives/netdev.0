From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Thu, 07 Apr 2011 13:06:12 +0200
Message-ID: <4D9D9AA4.6060304@trash.net>
References: <20110406184753.GA7691@mgebm.net> <1302115953.8094.217.camel@nimitz> <20110406212041.GA2596@mgebm.net> <20110406.142157.68145422.davem@davemloft.net> <20110406220512.GA2460@mgebm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dave@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, zbr@ioremap.net, gregkh@suse.de,
	ksrinivasan@novell.com, NetDev <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Eric B Munson <emunson@mgebm.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110406220512.GA2460@mgebm.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 07.04.2011 00:05, schrieb Eric B Munson:
> On Wed, 06 Apr 2011, David Miller wrote:
> 
>> From: Eric B Munson <emunson@mgebm.net>
>> Date: Wed, 6 Apr 2011 17:20:41 -0400
>>
>>> A bisect points at commit 04f482faf50535229a5a5c8d629cf963899f857c for the
>>> first bad one.  Unfortunately, I have not made netconsole work yet and the
>>> hang is happening mostly right when X starts so I can't even see the console.
>>> I will keep at the netconsole and see if I can get it functioning, also I will
>>> try to boot this kernel in a VM and see if that helps.
>>
>> Patrick, please help Eric so we can fix this bug.
>>
>> Thanks.
>>
> 
> I have a useful trace now from netconsole:
> 
> [   18.029521] BUG: sleeping function called from invalid context at arch/x86/mm/fault.c:1087
> [   18.029527] in_atomic(): 0, irqs_disabled(): 1, pid: 2018, name: cgrulesengd
> [   18.029693] BUG: unable to handle kernel paging request at 0000100000000000
> [   18.029730] IP: [<ffffffff814c3db8>] __skb_recv_datagram+0x128/0x2b0
> [   18.029756] PGD 0 
> [   18.029768] Oops: 0002 [#1] SMP 
> [   18.029790] last sysfs file: /sys/devices/pci0000:00/0000:00:02.0/0000:02:00.0/usb10/10-0:1.0/bInterfaceClass
> [   18.029824] CPU 0 
> [   18.029833] Modules linked in: kvm_intel kvm parport_pc ppdev snd_hda_codec_hdmi snd_hda_codec_realtek nfs lockd fscache auth_rpcgss nfs_acl sunrpc radeon deflate zlib_deflate ctr twofish_generic twofish_x86_64 twofish_common ttm camellia serpent drm_kms_helper snd_usb_audio blowfish cast5 snd_hda_intel drm des_generic snd_hda_codec snd_hwdep aesni_intel snd_usbmidi_lib cryptd aes_x86_64 aes_generic snd_pcm xcbc snd_seq_midi rmd160 snd_rawmidi sha512_generic sha256_generic uvcvideo snd_seq_midi_event sha1_generic snd_seq snd_timer crypto_null snd_seq_device snd af_key xhci_hcd i7core_edac videodev joydev psmouse edac_core v4l2_compat_ioctl32 w83627ehf soundcore serio_raw hwmon_vid snd_page_alloc max6650 hid_microsoft i2c_algo_bit lp parport asus_atk0110 usbhid hid firewire_ohci firewi
 re_core crc_itu_t
> [   18.030424] 
> [   18.030432] Pid: 2018, comm: cgrulesengd Not tainted 2.6.39-rc2+ #52 System manufacturer System Product Name/P6X58D PREMIUM
> [   18.030477] RIP: 0010:[<ffffffff814c3db8>]  [<ffffffff814c3db8>] __skb_recv_datagram+0x128/0x2b0
>...
> 
> I haven't dug into it at all, but I am happy to help test potential fixes.

I can't figure this out, the only thing that should have changed is the
time the initial PROC_CN_MCAST_LISTEN message is received. Apparently
at that point connector is not fully initialized yet. Please post your
config and the full boot log. Thanks.
