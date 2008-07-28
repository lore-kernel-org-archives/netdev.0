From: Peter Mallett <zl2bau@xnet.co.nz>
Subject: Re: baycom_ser_fdx - fixed under 2.6
Date: Mon, 28 Jul 2008 15:44:22 +1200
Message-ID: <488D4096.5000906@xnet.co.nz>
References: <alpine.DEB.1.10.0807191042050.21295@tombstone.paradise.gen.nz> <4885A8F6.7090109@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Robb <ender@paradise.gen.nz>, linux-hams@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Ralf Baechle <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pidoux <f6bvp@free.fr>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <4885A8F6.7090109@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pidoux wrote:
> Hi,
>
> This is a trivial but very important bug fix. Thanks David.
> It was probably not submitted to the right destination and thus never 
> applied.
>
> This bug may have discouraged more than one radioamateur wishing to 
> experiment baycom style modems under Linux.
> Fortunately you have done a very good historical search.
>
> I rebuilt the patch against 2.6.26 kernel (the only source I have here 
> on my laptop at my remote location during vacation).
>
> I Cc: to David Miller and Ralf Baechle DL5RB maintainers of Linux net 
> devices drivers and Linux AX25 drivers, respectively.
>
> 73 de Bernard, f6bvp
>
>
> --- a/drivers/net/hamradio/hdlcdrv.c    2008-07-22 10:40:20.000000000 
> +0200
> +++ b/drivers/net/hamradio/hdlcdrv.c    2008-07-22 10:42:13.000000000 
> +0200
> @@ -88,6 +88,7 @@
>  static inline void append_crc_ccitt(unsigned char *buffer, int len)
>  {
>       unsigned int crc = crc_ccitt(0xffff, buffer, len) ^ 0xffff;
> +    buffer += len;
>      *buffer++ = crc;
>      *buffer++ = crc >> 8;
>  }
>
>
>
> David Robb wrote :
>> So it seems that I might be the only person in the world who's still 
>> attempting to use a Baycom bp-1 pocket modem under Linux, but oh well..
>>
>> As a number of people noticed back in about 2005 (and some even 
>> earlier), the baycom_ser_fdx driver hasn't worked under Linux 2.6 for 
>> a few years (possibly ever).
>>
>> Various people poked around 
>> (http://osdir.com/ml/hams/2005-05/msg00022.html) and determined that 
>> there was some kind of packet corruption going on, and that the CRC 
>> was mangled.
>>
>> Well, after bashing my head against it a few times over the last few 
>> months (I guess I was bored), and finally thinking that it mightn't 
>> be in the baycom_ser_fdx driver that the problem actually was, I 
>> tracked it down to the hdlcdrv code instead...
>>
>> Someone called Micah actually figured this out in 2004, and submitted 
>> a patch, but it never made it into the kernel (at least in my 
>> 2.6.25.7 it's still broken):
>>
>> http://linux.derkeiler.com/Mailing-Lists/Kernel/2004-11/2929.html
>>
>> The CRC's overwriting some of the packet...
>>
>> So anyway, applying the patch listed at that URL (1 line! Just one 
>> little line!) my BP-1 now works again under 2.6.25.
>>
>> Perhaps I'm strange for wanting this working in these days of high 
>> speed links, but hey... it seems sad to have broken code and no 
>> support where there used to be a functional device.
>>
>> Anyway, share and enjoy.
>>
>> --David ZL3UDR
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-hams" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Hi,

    The Baycom MoDem problem is one I have battled for quite a while here.

How do I apply this patch to my Ubuntu 2.6.20-17-generic kernel.

I have the linux-source-2.6.20-2.6.20 source so which file do I apply 
the patch too ?

Then I need to recompile it ?

Would this bug also affect the SCC Baycom card ?

Regards ..... Peter

