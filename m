From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: HalfSipHash Acceptable Usage
Date: Mon, 19 Dec 2016 18:32:44 +0100
Message-ID: <CAHmME9rPmH=wP_eHYopt8ZPG9TSN7bos3fGOuqKL2HjQW-2SWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Theodore Ts'o" <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        David Laight <David.Laight@aculab.com>,
        David Miller <davem@davemloft.net>,
        Andi Kleen <ak@linux.intel.com>,
        George Spelvin <linux@sciencehorizons.net>,
        kernel-hardening@lists.openwall.com,
        Andy Lutomirski <luto@amacapital.net>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Vegard Nossum <vegard.nossum@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi JP,

With the threads getting confusing, I've been urged to try and keep
the topics and threads more closely constrained. Here's where we're
at, and here's the current pressing security concern. It'd be helpful
to have a definitive statement on what you think is best, so we can
just build on top of that, instead of getting lost in the chorus of
opinions.

1) Anything that requires actual long-term security will use
SipHash2-4, with the 64-bit output and the 128-bit key. This includes
things like TCP sequence numbers. This seems pretty uncontroversial to
me. Seem okay to you?

2) People seem to want something competitive, performance-wise, with
jhash if it's going to replace jhash. The kernel community
instinctively pushes back on anything that could harm performance,
especially in networking and in critical data structures, so there
have been some calls for something faster than SipHash. So, questions
regarding this:

2a) George thinks that HalfSipHash on 32-bit systems will have roughly
comparable speed as SipHash on 64-bit systems, so the idea would be to
use HalfSipHash on 32-bit systems' hash tables and SipHash on 64-bit
systems' hash tables. The big obvious question is: does HalfSipHash
have a sufficient security margin for hashtable usage and hashtable
attacks? I'm not wondering about the security margin for other usages,
but just of the hashtable usage. In your opinion, does HalfSipHash cut
it?

2b) While I certainly wouldn't consider making the use case in
question (1) employ a weaker function, for this question (2), there
has been some discussion about using HalfSipHash1-3 (or SipHash1-3 on
64-bit) instead of 2-4. So, the same question is therefore posed:
would using HalfSipHash1-3 give a sufficient security margin for
hashtable usage and hashtable attacks?

My plan is essentially to implement things according to your security
recommendation. The thread started with me pushing a heavy duty
security solution -- SipHash2-4 -- for _everything_. I've received
understandable push back on that notion for certain use cases. So now
I'm trying to discover what the most acceptable compromise is. Your
answers on (2a) and (2b) will direct that compromise.

Thanks again,
Jason
