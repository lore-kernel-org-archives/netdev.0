From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Thu, 18 Nov 2004 18:49:11 -0500
Message-ID: <20041118234911.GA66056@calma.pair.com>
References: <20041118220719.GA9890@gondor.apana.org.au> <OFE512064F.DBA4A3CD-ON88256F50.007A2A62-88256F50.007A5E0F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFE512064F.DBA4A3CD-ON88256F50.007A2A62-88256F50.007A5E0F@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Assuming so, another solution would be to stat/fstat the file, add some to 
> it to account
> for growth, allocate a buffer that big and read the whole thing in one 
> shot. Then the
> results should be self-consistent.

Yeah the kernel doesn't let you read more than 1 page of data.  Thats how big
the block of memory that it passes to the proc handler is.

http://lxr.linux.no/source/fs/proc/generic.c#L61

IIRC, each line in /proc/net/tcp is 115 bytes or something like that, so if
a page is 4k, then you can only read 4096/115 = 35 sockets worth of info per 
read() call.

Chad
