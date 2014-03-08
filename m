From: =?ISO-8859-1?Q?Jan-Simon_M=F6ller?= <dl9pf-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: LLVMLinux: Remove VLAIS usage from mac80211
Date: Sun, 09 Mar 2014 00:41:41 +0100
Message-ID: <fcb4c551-996e-42e4-a9ff-ac3c8f3bc5ea@email.android.com>
References: <1394177091.4653.1.camel@jlt4.sipsolutions.net> <1394241960-1764-1-git-send-email-behanw@converseincode.com> <CABikg9y_j-SDOsMj1C5uogP0HNj6bsB_ySVFtAh_oNgZ0swd=g@mail.gmail.com> <531B934C.31666.37555A14@pageexec.freemail.hu> <CABikg9x+Z95bHcDc6iu5hBvRNO-ibM8-34_qA+OA_FjB52SPMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: behanw-k/hB3zQhLwledRVtV/plodBPR1lH4CV8@public.gmane.org, John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	=?ISO-8859-1?Q?Vin=EDcius_Tinti?= <viniciustinti-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mark Charlebois <charlebm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Sergei Antonov <saproj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CABikg9x+Z95bHcDc6iu5hBvRNO-ibM8-34_qA+OA_FjB52SPMw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 9. M=C3=A4rz 2014 00:00:19 MEZ, Sergei Antonov <saproj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
>On 8 March 2014 23:01, PaX Team <pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org> wrote:
>> On 8 Mar 2014 at 21:29, Sergei Antonov wrote:
>>
>>> > -       memset(&aead_req, 0, sizeof(aead_req));
>>> > +       char aead_req_data[sizeof(struct aead_request) +
>>> > +                               crypto_aead_reqsize(tfm) +
>>> > +                               CRYPTO_MINALIGN]
>CRYPTO_MINALIGN_ATTR;
>>                                                    =20
>^^^^^^^^^^^^^^^^^^^^
>> wouldn't the underlined attribute ensure the required alignment?
>Yes. Sorry, I overlooked it.
>
>I would remove unneeded CRYPTO_MINALIGN and get the alignment from the
>target structure:
>        char aead_req_data[sizeof(struct aead_request) +
>                           crypto_aead_reqsize(tfm)]
>        __attribute__((__aligned__(__alignof__(struct aead_request))))=
;



LGTM



--=20
Diese Nachricht wurde von meinem Android-Mobiltelefon mit K-9 Mail gese=
ndet.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
