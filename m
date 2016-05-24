From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RESEND 7/8] pipe: account to kmemcg
Date: Tue, 24 May 2016 13:04:33 -0700
Message-ID: <1464120273.5939.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
	 <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
	 <1464094742.5939.46.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160524161336.GA11150@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
 <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal
 Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org,  netdev@vger.kernel.org, x86@kernel.org,
 linux-kernel@vger.kernel.org
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160524161336.GA11150@esperanza>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-24 at 19:13 +0300, Vladimir Davydov wrote:
> On Tue, May 24, 2016 at 05:59:02AM -0700, Eric Dumazet wrote:
> ...
> > > +static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
> > > +			       struct pipe_buffer *buf)
> > > +{
> > > +	struct page *page = buf->page;
> > > +
> > > +	if (page_count(page) == 1) {
> > 
> > This looks racy : some cpu could have temporarily elevated page count.
> 
> All pipe operations (pipe_buf_operations->get, ->release, ->steal) are
> supposed to be called under pipe_lock. So, if we see a pipe_buffer->page
> with refcount of 1 in ->steal, that means that we are the only its user
> and it can't be spliced to another pipe.
> 
> In fact, I just copied the code from generic_pipe_buf_steal, adding
> kmemcg related checks along the way, so it should be fine.

So you guarantee that no other cpu might have done
get_page_unless_zero() right before this test ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
