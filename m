From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 1/7] hashtable: introduce a small and naive hashtable
Date: Fri, 3 Aug 2012 15:23:39 -0700
Message-ID: <20120803222339.GN15477@google.com>
References: <1344003788-1417-1-git-send-email-levinsasha928@gmail.com>
 <1344003788-1417-2-git-send-email-levinsasha928@gmail.com>
 <20120803171515.GH15477@google.com>
 <501C407D.9080900@gmail.com>
 <20120803213017.GK15477@google.com>
 <501C458E.7050000@gmail.com>
 <20120803214806.GM15477@google.com>
 <501C4E92.1070801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	paul.gortmaker@windriver.com, davem@davemloft.net,
	rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
	aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <501C4E92.1070801@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Aug 04, 2012 at 12:20:02AM +0200, Sasha Levin wrote:
> On 08/03/2012 11:48 PM, Tejun Heo wrote:
> > On Fri, Aug 03, 2012 at 11:41:34PM +0200, Sasha Levin wrote:
> >> I forgot to comment on that one, sorry.
> >>
> >> If we put hash entries after struct hash_table we don't take the
> >> bits field size into account, or did I miss something?
> > 
> > So, if you do the following,
> > 
> > 	struct {
> > 		struct {
> > 			int i;
> > 			long ar[];
> > 		} B;
> > 		long __ar_storage[32];
> > 	} A;
> 
> struct A should have been an union, right?

I actually meant an enclosing struct.  When you're defining a struct
member, simply putting the storage after a struct with var array
should be good enough.  If that doesn't work, quite a few things in
the kernel will break.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
