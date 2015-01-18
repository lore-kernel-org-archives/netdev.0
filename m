From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Wireless scanning while turning off the radio problem..
Date: Sun, 18 Jan 2015 20:52:44 +0200
Message-ID: <CANUX_P1pmB2PD00N2r2LgjNL4fG6RuTPxsO8G2weU+8EeENPTg@mail.gmail.com>
References: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
	<CANUX_P0LCr3fzqLyjKQbZ-P2hAV-Nk6=AMm=oFOWCLW34cRg2w@mail.gmail.com>
	<CA+55aFzEr-R1anNm91pnM=ujfhBstJikZBVtduphff1PtccHDw@mail.gmail.com>
	<54BBF207.2030708@broadcom.com>
	<CA+55aFws=-MY+rUsEny=DsBx9gct93BnfeGXSnOCLxEFtvDj8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+55aFws=-MY+rUsEny=DsBx9gct93BnfeGXSnOCLxEFtvDj8A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 18, 2015 at 8:40 PM, Linus Torvalds
<torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> On Mon, Jan 19, 2015 at 5:48 AM, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
>>
>> So as you indicated you were in location where none of your configured
>> networks were available. Flipping the rfkill switch in that situation is the
>> way to trigger the issue.
>
> So you certainly seem to be able to explain the behavior I saw under
> the circumstances they happened.
>
> I suspect the best thing to do is to just apply your patch. I may not
> be able to really test it much for the next few days anyway. Emmanuel?
>

Sorry - I was a bit busy.
The patch seems wrong, we can't really call that function from the
rfkill interrupt - it will blow up.
The good news is that I could reproduce the bug based on what Arend
pointed. I totally missed the fact
that it was scheduled scan - thanks Arend for that.

So the system I have here doesn't have HW rfkill so I had to implement
a hook that fakes it,
but I can't reproduce the problem.
I'll come up with a patch.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
