From: Dmitry Yusupov <dima@neterion.com>
Subject: Re: iSCSI and scatterlists
Date: Wed, 16 Mar 2005 11:59:42 -0800
Message-ID: <1111003182.27052.46.camel@beastie>
References: <200503160209.j2G29cAf010870@hera.kernel.org>
	 <20050316075839.GC7842@suse.de> <1110986016.5771.3.camel@mulgrave>
	 <20050316160447.GU7842@suse.de>
	 <20050316164806.GO21986@parcelfarce.linux.theplanet.co.uk>
	 <20050316165338.GX7842@suse.de> <20050316170259.GA25056@infradead.org>
	 <20050316170417.GY7842@suse.de> <42387EA2.5020106@us.ibm.com>
	 <20050316185310.GQ21986@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Christie <mikenc@us.ibm.com>, Jens Axboe <axboe@suse.de>,
        Christoph Hellwig <hch@infradead.org>,
        James Bottomley <James.Bottomley@SteelEye.com>,
        SCSI Mailing List <linux-scsi@vger.kernel.org>, netdev@oss.sgi.com,
        open-iscsi@googlegroups.com
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20050316185310.GQ21986@parcelfarce.linux.theplanet.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-16 at 18:53 +0000, Matthew Wilcox wrote:
> On Wed, Mar 16, 2005 at 10:44:50AM -0800, Mike Christie wrote:
> > I got lost here. If you are talking about the need to kmap a sglist then 
> > software iscsi has it. iscsi-sfnet used to do
> > 
> > while (...)
> > 	kmap()
> > 
> > but I fixed that (I think I need to use kmap_atomic though, is that 
> > correct or is it just a performance improvement - I am calling kmap from 
> > a thread too so). I just added kmap_atomic to open-iscsi and I believe 
> > pyx does something similar to the loop above.
> 
> Sounds like networking should grow an interface to accept a sglist as
> input.  I'm really not familiar with Linux's networking stack to know
> how to do it ... cc'ing netdev to get their thoughts.

This is a nice idea, but will not always work with iSCSI protocol simply
because iSCSI PDU's data sizes might be negotiated to be lesser/bigger
than original WRITE's sglist size. It might help to optimize some data
path when PDU's data segment size >= sglist size. i.e. entire sglist
needs to be passed down to the stack.

i'm cross-posting to open-iscsi mailing list, so open-iscsi folks might
participate in the discussion.

Dmitry
