From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Thu, 7 Apr 2016 08:11:51 -0700
Message-ID: <570678B7.7010802@sandisk.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com> <20160407143854.GA7685@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Tom Herbert
	<tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>,
	"lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>, linux-mm
	<linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Christoph Hellwig <hch@infradead.org>, Jesper Dangaard Brouer
	<brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160407143854.GA7685@infradead.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 04/07/16 07:38, Christoph Hellwig wrote:
> This is also very interesting for storage targets, which face the same
> issue.  SCST has a mode where it caches some fully constructed SGLs,
> which is probably very similar to what NICs want to do.

I think a cached allocator for page sets + the scatterlists that 
describe these page sets would not only be useful for SCSI target 
implementations but also for the Linux SCSI initiator. Today the scsi-mq 
code reserves space in each scsi_cmnd for a scatterlist of 
SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page 
sets less memory would be needed per scsi_cmnd. See also 
scsi_mq_setup_tags() and scsi_alloc_sgtable().

Bart.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
