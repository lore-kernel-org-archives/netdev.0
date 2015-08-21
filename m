From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: DEBUG_LOCKS_WARN_ON(in_interrupt()) triggering in socket code
Date: Fri, 21 Aug 2015 16:09:00 +0200
Message-ID: <20150821140900.GB17065@unicorn.suse.cz>
References: <CAHmME9p06qf36RPtROF767c5p37PggN12bSa9u8ZXgGGThA4BQ@mail.gmail.com>
 <CAHmME9qfvVbDuadThepz_37esYu-kFiUOeVoxpEmFn9doiEctg@mail.gmail.com>
 <CAHmME9pXVdT5aDcf04QUQbrjTh4LpsqcWJeS1Etjf_2E08GM2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55866 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239AbbHUOJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 10:09:03 -0400
Content-Disposition: inline
In-Reply-To: <CAHmME9pXVdT5aDcf04QUQbrjTh4LpsqcWJeS1Etjf_2E08GM2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 21, 2015 at 03:42:33PM +0200, Jason A. Donenfeld wrote:
> Ahhh, interesting, so it turns out you can't do a number of things
> with a read_lock_bh held, because it increases the softirq count.
> Mystery solved.

You must not do anything that can sleep (like taking a mutex) while
holding a rwlock (even for reading) as someone else could call
write_lock() on the same rwlock on the same CPU in the meantime and
would end up spinning indefinitely while waiting for you to release it.

                                                        Michal Kubecek
