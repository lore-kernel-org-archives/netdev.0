From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: linux 2.6.9: r8169: eth0: PCI error (status: 0x8404). Device disabled.
Date: Thu, 21 Oct 2004 14:02:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021120208.GA752@electric-eye.fr.zoreil.com>
References: <1098269117.6631.5.camel@ukabzc383.uk.saic.com> <20041020121520.GA4004@electric-eye.fr.zoreil.com> <1098282567.6631.10.camel@ukabzc383.uk.saic.com> <20041020201010.GA13023@electric-eye.fr.zoreil.com> <1098350743.15528.40.camel@ukabzc383.uk.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eamonn Hamilton <EAMONN.HAMILTON@saic.com>
Content-Disposition: inline
In-Reply-To: <1098350743.15528.40.camel@ukabzc383.uk.saic.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eamonn Hamilton <EAMONN.HAMILTON@saic.com> :
[...]
> As you surmised, the card seems to work OK under moderate load, but
> under havy transmit load the error occurs. It hasn't been seen under
> Anyway, I now have 2.6.9 patched with the patch you sent with NAPI
> enabled, 2.6.7 and 2.6.8 installed. I'm also going to install another
> kernel with the code you mentioned commented out as follows, yes ?
> 
> if (unlikely(status & SYSErr)) {
>    /* rtl8169_pcierr_interrupt(dev); */
>    break;

Yep.
This is a gross hack but it is the first time that an unexpected
PCI error is reported on x86 (they are expected when I do fancy
testing :o) ). So I wonder if it really harms.

> You also mentioned being able to enable TX checksum and segmentation
> offload - how do I enable this, is it through ethtool or something more
> esoteric?

ethtool -K ethX tx on sg on tso on

You'll need the patch for TSO that M. Xu posted a few days ago. It is in
the vanilla tree and will appear in the upcoming -bk snapshot.

> Thanks again for the help, hopefully I'll be able to get this lot tested
> over the next couple of days and let you know how it went.

Apparently there is a Master Abort which exhibits zero difference with the
amd64 DAC error. The current code is only enough for my home system to
recover from PCI error issued by the 8169. It will have to be tweaked.

--
Ueimor
