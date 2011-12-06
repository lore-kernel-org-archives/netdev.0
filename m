From: Damien Millescamps <damien.millescamps@6wind.com>
Subject: Re: v6: faster tree-based sysctl implementation
Date: Tue, 06 Dec 2011 17:47:09 +0100
Message-ID: <4EDE470D.3070808@6wind.com>
References: <CAPLs8y9omncDbLE_KNoKOLLbfwHjWYUJX_i7cC4bLiJsyPbtZQ@mail.gmail.com> <CAJL_dMtgP+BqFn3aGVBbGDJ+kMyGiEC_NmDURzh4mU=Jo=qZVA@mail.gmail.com> <CAPLs8y8vhioqc3CPrD7ugmVkR2DjKWNm8+T5j9QQnrxi=BgvdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W . Biederman" <ebiederm@xmission.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPLs8y8vhioqc3CPrD7ugmVkR2DjKWNm8+T5j9QQnrxi=BgvdA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06/2011 03:33 PM, Lucian Adrian Grijincu wrote:
> On Tue, Dec 6, 2011 at 4:11 PM, Anca Emanuel<anca.emanuel@gmail.com>  wrote:
>> time modprobe dummy numdummies=1000FATAL: Error inserting dummy
>> (/lib/modules/3.2.0-3-generic/kernel/drivers/net/dummy.ko): Operation
>> not permitted
> Generally when you get "Operation not permitted" you should try with sudo.
> This is the man-page: http://xkcd.com/149/ :)
>
>
>> What are the practical problems you solve with this ?
>> Name one or more.
>
> Sysctl uses a slow algorithm: O(N^2) for insertions, O(N) for lookup,
> with a relatively big constant.
> The performance is acceptable when N is small, but sometimes it can
> grow to bigger values.
> One case where N can grow to very large values is when you add network
> interfaces.
>
> Some companies (like IXIACOM which sponsored this work at the
> beginning of this year) have use-cases in which they need 10^3..10^6
> network interfaces. The current sysctl implementation is unacceptable
> for them.
>
> @Damien Millescamps might have some input on where he needs better
> sysctl performance as he prompted me to re-send this patch series.
>
> This algorithm is O(N * logN) for insert and O(logN) for lookup.
>
>

A use-case for wanting to be able to create several interfaces is to 
have a "tunnel" server handling several dynamic point to point connections.

The current implementation dates from the "sysctl cleanup" from Al Viro: 
commits 734550921e9b7ab924a43aa3d0bd4239dac4fbf1 to 
ae7edecc9b8810770a8e5cb9a466ea4bdcfa8401, plus some later fixes.
This implementation was suboptimal, and modifying it necessitates a lot 
of reworking of the structures used, so the diff is clearly big. Also 
Lucian took time to add lots of comment to help understanding and using 
the new implementation, which also explains the amount of modifications 
in kernel/sysctl.c

For information, the main idea is to implement sysctl, which has a 
filesystem structure, like most other file system implementation (like 
sysfs), i.e. using an rb_tree.

-- 
damien
