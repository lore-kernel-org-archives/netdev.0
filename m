From: Steve Modica <modica@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 08 Oct 2003 14:11:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F846173.9090107@sgi.com>
References: <3F844578.40306@sgi.com>	<20031008101046.376abc3b.davem@redhat.com>	<3F844EF9.9090901@sgi.com> <20031008112657.2adddeb6.davem@redhat.com> <3F845F61.9080002@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnip@sgi.com
In-Reply-To: <3F845F61.9080002@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I think it'd be better to create some macro like this:

#ifdef FORCE_SKB_ALIGNMENT
# define SKB_COPY_CHECK(len) len > RX_COPY_THRESHOLD && tp->rx_offset == 2
#else
# define SKB_COPY_CHECK(len) len > RX_COPY_THRESHOLD
#endif

Then replace the code in the if with the new macro.  We can define 
FORCE_SKB_ALIGNMENT in our build environment as can others if necessary. 
otherwise, everyone does what they did before.

Steve



John Partridge wrote:
> OK, fair enough, you mean like :-
> 
> #if defined(__ia64__)
>     if (len > RX_COPY_THRESHOLD && tp->rx_offset == 2) {
> #else
>     if (len > RX_COPY_THRESHOLD) {
> #endif
> 
> 
> 
> David S. Miller wrote:
> 
>> On Wed, 08 Oct 2003 12:52:57 -0500
>> John Partridge <johnip@sgi.com> wrote:
>>
>>
>>> Not too much different
>>
>>
>>
>> The problem is that your change is arch-dependant yet you make it
>> run on all platforms.
>>
>> On x86 we don't want to do what your change is doing, the unaligned
>> accesses are cheap enough.
>>
>> We need to abstract this, probably in the same way it is done in
>> the Tulip and other drivers which have similar issues.
> 
> 


-- 
Steve Modica
work: 651-683-3224
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
