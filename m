From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Sat, 22 Nov 2014 03:36:39 +0000
Message-ID: <20141122033639.GY7996@ZenIV.linux.org.uk>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
 <20141119.161744.1661940121298888832.davem@davemloft.net>
 <20141119213006.GE7996@ZenIV.linux.org.uk>
 <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <1416520542.8629.46.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141120222506.GS7996@ZenIV.linux.org.uk>
 <1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141121084956.GT7996@ZenIV.linux.org.uk>
 <20141122032718.GA24457@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, target-devel@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141122032718.GA24457@ZenIV.linux.org.uk>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 22, 2014 at 03:27:18AM +0000, Al Viro wrote:
  
> @@ -566,38 +445,15 @@ static size_t copy_to_iter_bvec(void *from, size_t bytes, struct iov_iter *i)
[snip]
> +	iterate_bvec(i, bytes, page, off, len, true,
> +		     memcpy_from_page((from += len) - len, page, off, len))

should be
+		     memcpy_to_page(page, off, (from += len) - len, len))

and

> @@ -605,35 +461,9 @@ static size_t copy_from_iter_bvec(void *to, size_t bytes, struct iov_iter *i)
[snip]
> +	iterate_bvec(i, bytes, page, off, len, true,
> +		     memcpy_to_page(page, off, (to += len) - len, len))

should be
+		     memcpy_from_page((to += len) - len, page, off, len))

Sorry, wrong delta.
