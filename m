From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Wed, 19 Nov 2014 12:40:53 -0800
Message-ID: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
References: <20141118084745.GT7996@ZenIV.linux.org.uk>
	<CA+55aFxK0wj2LLp0WmhRsBZch8XfoYbzmbEeJaMpt=SDh5GBvw@mail.gmail.com>
	<20141118212307.GU7996@ZenIV.linux.org.uk>
	<20141119.153136.867017618826698045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141119.153136.867017618826698045.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2014 at 12:31 PM, David Miller <davem@davemloft.net> wrote:
>
> But that is just my opinion, and yes I do acknowledge that we've had
> serious holes in this area in the past.

The serious holes have generally been exactly in the "upper layers
already check" camp, and then it turns out that some odd ioctl or
other thing ends up doing something odd and interesting.

If Al has actual performance profiles showing that the access_ok() is
a real problem, then fine. As a low-level optimization, I agree with
it. But not as a "let's just drop them, and make the security rules be
non-local and subtle, and require people to know the details of the
whole call-chain".

Seeing a "__get_user()" and just being able to glance up in the same
function and seeing the "access_ok()" is just a good safety net. And
means that people don't have to waste time thinking about or looking
for where the hell the security net really is.

                    Linus
