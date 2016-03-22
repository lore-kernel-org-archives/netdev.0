From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [Y2038] [PATCH] prism54: isl_38xx: Replace 'struct timeval'
Date: Tue, 22 Mar 2016 12:51:11 +0100
Message-ID: <4052607.z5Cu6oJFz8@wuerfel>
References: <20160322095522.GA35392@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Tina Ruchandani <ruchandani.tina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160322095522.GA35392@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 March 2016 02:55:22 Tina Ruchandani wrote:
> Truly fixing this would 
> require changing the debug print to print more than 8 digits and using 
> a different specifier from %li.

Why not just change it to %lli, and a cast to s64? I don't think the
format string or the number of digits is important here because it's just
debug output that is normally disabled.

I also see an existing bug in the format string: "%08li.%08li" means we
end up printing a six digit microsecond value with two leading zeros,
which is rather confusing. I think using "%lld.%06ld" would be best
here, or possibly "%lld.%09ld" to print the whole nanoseconds so we
can skip the division.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
