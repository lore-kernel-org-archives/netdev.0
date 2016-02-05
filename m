From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v2 2/4] lib: update single-char callers of strtobool
Date: Fri, 5 Feb 2016 13:18:04 -0800
Message-ID: <CAGXu5jJrFv5Y8Q_i3yFYBDmT0+pO05dS3ijB0gOn-huasxZWmA@mail.gmail.com>
References: <1454619643-14444-1-git-send-email-keescook@chromium.org>
	<1454619643-14444-3-git-send-email-keescook@chromium.org>
	<063D6719AE5E284EB5DD2968C1650D6D1CCD6FE5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	"linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Andy Shevchenko <andy.shevchenko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Michael Ellerman <mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org>,
	Heiko Carstens <heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	Martin Schwidefsky <schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>,
	"x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TbrhsbdSgBK9A@public.gmane.org
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCD6FE5-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-cifs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 5, 2016 at 2:46 AM, David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org> wrote:
> From: Kees Cook
>> Sent: 04 February 2016 21:01
>> Some callers of strtobool were passing a pointer to unterminated strings.
>> In preparation of adding multi-character processing to kstrtobool, update
>> the callers to not pass single-character pointers, and switch to using the
>> new kstrtobool_from_user helper where possible.
>
> Personally I think you should change the name of the function so that the
> compiler (and linker) will pick up places that have not been changed.
> Relying on people to make the required changes will cause problems.

After the single-character users were pointed out, I looked for others
and there aren't any.

> The current code (presumably) treats "no", "nyet" and "nkjkkrkjrkjterkj" as false.
> Changing that behaviour will break things.

There's no change there. All three of those will still be "false".
Perhaps my changelog shouldn't say "unterminated" but rather
"character array".

> If you want to support "on" and "off", then maybe check for the supplied string
> starting with the character sequences "on\0" and "off\0" (as well as any others).
> This doesn't need the input string be '\0' terminated - since you match y and n
> without looking at the 2nd byte.
> You'd have to be extremely unlucky to get a page fault in the 3 bytes
> following an 'o' if the caller supplied a single byte buffer.

I'd prefer to keep the switch statement as short as possible, and I
don't want to do full string compares. And as you say, even fixing the
single-byte callers seems like a needless exercise, but seeing as how
it's a net clean-up, I think it's good they way I've got the series.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
