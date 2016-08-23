From: Edward Cree <ecree@solarflare.com>
Subject: Re: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 17:46:14 +0100
Message-ID: <f3fa1ab8-c7de-8dd0-f7db-c058483941a1@solarflare.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
 <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
 <1471962096.14381.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <1471964716.3746.103.camel@perches.com>
 <1471966619.14381.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Luis Henriques <luis.henriques@canonical.com>,
        Avijit Kanti Das <avijitnsec@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>,
        "Ben Hutchings" <ben@decadent.org.uk>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471966619.14381.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/08/16 16:36, Eric Dumazet wrote:
> On Tue, 2016-08-23 at 08:05 -0700, Joe Perches wrote:
>
>> A compiler does not have a standards based requirement to
>> initialize arbitrary padding bytes.
>>
>> I believe gcc always does zero all padding anyway.
> Even if the current standards are lazy (are they, I did not check ?),
> security needs would call for a sane compiler behavior and changing the
> standards accordingly.
Sadly C99 is: section 6.2.6.1.6 (in draft N1256) says
  "When a value is stored in an object of structure or union type,
   including in a member object, the bytes of the object representation
   that correspond to any padding bytes take unspecified values."
with a footnote (42) reading
  "Thus, for example, structure assignment need not copy any padding bits."

In C11 (or, at least, draft N1570), the corresponding text is identical,
only the footnote number has changed (51).
HOWEVER, section 6.7.9.10 has changed, and now (for static objects) reads:
  "if it is an aggregate, every member is initialized (recursively)
   according to these rules, _and_any_padding_is_initialized_to_zero_bits_"
(emphasis added).
On the other hand, a sufficiently pedantic (and perverse) language lawyer
could argue that the initialiser only "specifies the initial value stored
in an object" (6.7.9.8), and that when a value is 'stored in an object'
section 6.2.6.1.6 applies to the storing process after the initial value
has been constructed.
On the gripping hand, such an interpretation would cause the new 6.7.9.10
language to have no observable effect, and thus clearly cannot be what was
intended by the C11 committee.

Aren't you glad you asked?

In any case, there is more to life than standards lawyering, compilers
that don't zero the padding bytes are as a practical matter broken even
though not in violation of the (C99) standard.  Besides, it's not as if
Linux doesn't already have requirements on its compilers that go beyond
the standards...

-Ed
