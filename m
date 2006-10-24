From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: [RFC] [PATCH 1/3] adds iso3166-1 support
Date: Tue, 24 Oct 2006 11:59:34 -0400
Message-ID: <43e72e890610240859o39a42658p64d198a2130e3f87@mail.gmail.com>
References: <43e72e890610231545n389d8a6dy89bb476101953234@mail.gmail.com>
	 <1161678617.2840.5.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Jiri Benc" <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jean Tourrilhes" <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:5909 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S965101AbWJXP7g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 11:59:36 -0400
Received: by wr-out-0506.google.com with SMTP id i4so362227wra
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2006 08:59:35 -0700 (PDT)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1161678617.2840.5.camel@ux156>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/24/06, Johannes Berg <johannes@sipsolutions.net> wrote:
>
>
> > +static int load_iso3166_1(void) {
> > +       int r = 0;
> > +       r |= iso3166_1_add(4, "AF", "AFG",
> > +               "Afghanistan");
> [...]
>
> Why don't you make the table a static array, then you can use ARRAY_SIZE
> and get rid of the whole list_head, not have it eat up code size and
> mark it as read-only static data.

This was how I had the original implementation, I moved it to linked
lists thinking we'd update it frequently but obviously that's not the
case. You are right, also if we index based on alpha3 we get O(1)
access to the elements. Will make these changes.

> > +EXPORT_SYMBOL(iso3166_1_list);
>
> Why export the list?

No good reason -- will remove this, right again.

> > +EXPORT_SYMBOL(get_iso3166_1_numeric);
> > +EXPORT_SYMBOL(get_iso3166_1_alpha2);
> > +EXPORT_SYMBOL(get_iso3166_1_alpha3);
> > +EXPORT_SYMBOL(iso3166_1_exists);
>
> Also, please put these along with the function.

Sure.

  Luis
