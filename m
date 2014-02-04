From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
Date: Tue, 04 Feb 2014 10:57:05 -0800
Message-ID: <87r47ik8ou.fsf@xmission.com>
References: <87r47jsb2p.fsf@xmission.com>
	<1391530721.4301.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<871tzirdwf.fsf@xmission.com>
	<1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Tue, 04 Feb 2014 10:44:24 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Tue, 2014-02-04 at 09:22 -0800, Eric W. Biederman wrote:
>
>> The two code paths below certainly look good canidates for having
>> __GFP_NORETRY added to them.  The same issues I ran into with
>> alloc_fdmem are likely to show up there as well.
>
> Yes, this is what I thought : a write into TCP socket should be more
> frequent than the alloc_fdmem() case ;)
>
> But then, maybe your workload was only using UDP ?

As I have heard it described one tcp connection per small requestion,
and someone goofed and started creating new connections when the server
was bogged down.  But since all of the requests and replies were small I
don't expect even TCP would allocate more than a 4KiB page in that
worload.

I had oodles of 4KiB and 8KiB pages.  What size of memory allocation did
you see failing?  

Eric
