From: Sergei Antonov <saproj@gmail.com>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Sun, 9 Mar 2014 00:00:19 +0100
Message-ID: <CABikg9x+Z95bHcDc6iu5hBvRNO-ibM8-34_qA+OA_FjB52SPMw@mail.gmail.com>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net>
	<1394241960-1764-1-git-send-email-behanw@converseincode.com>
	<CABikg9y_j-SDOsMj1C5uogP0HNj6bsB_ySVFtAh_oNgZ0swd=g@mail.gmail.com>
	<531B934C.31666.37555A14@pageexec.freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: behanw@converseincode.com, John Linville <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>, davem@davemloft.net,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>,
	=?UTF-8?Q?Jan=2DSimon_M=C3=B6ller?= <dl9pf@gmx.de>,
	=?UTF-8?Q?Vin=C3=ADcius_Tinti?= <viniciustinti@gmail.com>,
	Mark Charlebois <charlebm@gmail.com>
To: pageexec@freemail.hu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <531B934C.31666.37555A14@pageexec.freemail.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8 March 2014 23:01, PaX Team <pageexec@freemail.hu> wrote:
> On 8 Mar 2014 at 21:29, Sergei Antonov wrote:
>
>> > -       memset(&aead_req, 0, sizeof(aead_req));
>> > +       char aead_req_data[sizeof(struct aead_request) +
>> > +                               crypto_aead_reqsize(tfm) +
>> > +                               CRYPTO_MINALIGN] CRYPTO_MINALIGN_ATTR;
>                                                      ^^^^^^^^^^^^^^^^^^^^
> wouldn't the underlined attribute ensure the required alignment?
Yes. Sorry, I overlooked it.

I would remove unneeded CRYPTO_MINALIGN and get the alignment from the
target structure:
        char aead_req_data[sizeof(struct aead_request) +
                           crypto_aead_reqsize(tfm)]
                __attribute__((__aligned__(__alignof__(struct aead_request))));
