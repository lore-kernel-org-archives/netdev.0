From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 79891] New: Router causes TCP retransmits for windows
 hosts after "ip_forward: fix inverted local_df test"
Date: Fri, 11 Jul 2014 12:14:48 -0700 (PDT)
Message-ID: <20140711.121448.272840314486162433.davem@davemloft.net>
References: <1405102310.26540.83.camel@deadeye.wl.decadent.org.uk>
	<CAHA+R7PDJ42Y1Wovtw=dzN-JqQjcamPtDPSmS_SyUK95JNp_aA@mail.gmail.com>
	<1405105272.26540.88.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1405105272.26540.88.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 11 Jul 2014 20:01:12 +0100

> On Fri, 2014-07-11 at 11:38 -0700, Cong Wang wrote:
>> On Fri, Jul 11, 2014 at 11:11 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
>> > On Thu, 2014-07-10 at 10:11 -0700, Cong Wang wrote:
>> >> On Thu, Jul 10, 2014 at 6:44 AM, Stephen Hemminger
>> >> <stephen@networkplumber.org> wrote:
>> >> >
>> >> > After upgrading a router to Linux 3.2.60 most windows machines behind it
>> >> > started experiencing connection stalls. Downgrade to 3.2.59 resolved the
>> >> > problem. Using git bisect I pinpointed it to
>> >> > "59d9f389df3cdf72833d5ee17c3fe959b6bdc792 is the first bad commit", which
>> >> > entered the kernel from here
>> >> > http://marc.info/?l=linux-netdev&m=139949081418806&w=2
>> >> >
>> >>
>> >> This commit should have been reverted for older kernels like 3.2.y.
>> >
>> > Really?  We already had fe6cc55f3a9 ("net: ip, ipv6: handle gso skbs in
>> > forwarding path") backported in 3.2.57.
>> 
>> I haven't read the code, but according to a previous discussion it sounds
>> like that should be reverted:
>> 
>> http://lists.openwall.net/netdev/2014/06/11/67
> 
> My reading of that is we need 895162b1101b ("netfilter: ipv4: defrag:
> set local_df flag on defragmented skb") in 3.2.y and 3.4.y.  But there
> seem to be many other places that local_df should be set, that have only
> recently been fixed.  So maybe reverting is the safer option.

Reverting is indeed probably safer.
