From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 09:12:03 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410110858350.4733@portland.hansa.lan>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        David Gibson <hermes@gibson.dropbear.id.au>
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net>
To: Cal Peake <cp@absolutedigital.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 11 Oct 2004, Cal Peake wrote:

> This patch fixes several dozen warnings spit out when compiling the hermes
> wireless driver.

I noticed them too.

By the way, it would be nice to move the discussion to the mailing list of 
the driver, orinoco-devel@lists.sourceforge.net.  Sorry that it wasn't 
mentioned in the MAINTAINERS file.  I've just submitted a patch to add the 
mailing lists to that file.

> @@ -364,12 +364,12 @@
> /* Register access convenience macros */
> #define hermes_read_reg(hw, off) ((hw)->io_space ? \
> 	inw((hw)->iobase + ( (off) << (hw)->reg_spacing )) : \
> -	readw((hw)->iobase + ( (off) << (hw)->reg_spacing )))
> +	readw((void __iomem *)(hw)->iobase + ( (off) << (hw)->reg_spacing )))

The HEAD version of the driver aims to support Linux starting with version 
2.4.10, so you need to add some magic in kcompat.h to define __iomem.

HostAP driver uses cast to (void *), which compiles without warnings.  I 
believe it's sufficient because the call to readw() would cast the 
argument to whatever readw() needs.

Another, more sophisticated solution would be to use union for iobase:

typedef struct hermes {
         union {
                 unsigned long io;
                 void *mem;
         } base;
         int io_space; /* 1 if we IO-mapped IO, 0 for memory-mapped IO? */
 	...
}

-- 
Regards,
Pavel Roskin
