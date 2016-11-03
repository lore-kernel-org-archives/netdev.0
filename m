From: John Heenan <john-AMlJbUfTsso@public.gmane.org>
Subject: Re: [PATCH 1/2] rtl8xxxu: Fix for authentication failure
Date: Thu, 3 Nov 2016 17:10:58 +1000
Message-ID: <CAAye0QNZYjg1NDmXmjMXNJqa7nsbvfgoX8et1g1+HT2S2O=L1w@mail.gmail.com>
References: <cover.1477769750.git.john@zgus.com> <20161030102046.GA5784@cube> <8dba6346-332e-84e6-89b2-02033a449f25@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8dba6346-332e-84e6-89b2-02033a449f25-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3 November 2016 at 11:00, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote=
:
> On 10/30/2016 05:20 AM, John Heenan wrote:
>>
>> This fix enables the same sequence of init behaviour as the alternative
>> working driver for the wireless rtl8723bu IC at
>> https://github.com/lwfinger/rtl8723bu
>>
>> For exampe rtl8xxxu_init_device is now called each time
>> userspace wpa_supplicant is executed instead of just once when
>> modprobe is executed.
>
>
> After all the trouble you have had with your patches, I would expect you =
to
> use more care when composing the commit message. Note the typo in the
> paragraph above.
>

OK, the nasty games continue and the message is not getting through.

An appropriate response by a maintainer would have been to request I
revise the code according to the way it has currently and elegantly
revised in.

[PATCH v2] rtl8xxxu: Fix for agressive power saving by rtl8723bu wireless I=
C

where I use a simple pointer comparison of priv->fops with &rtl8723bu_fops.

As far as I can see there is nothing more to be done on my part code
wise. The supposed issue with matching functions, as far as I can see,
is a non issue.

If you want to comment on comments in patch messages please do so on
the above current proposed patch instead of dragging up stale and
irreelvant patch proposals to make a petty point.

Jes has now moved the goal posts, indicating all drivers for rtl8xxxu
need to be tested fro similar issues. If there are problems with other
rtl8xxxu drives then it is not my problem and has nothing to do with
me. My issue is only with the rtl8723bu driver.

Such doubts also makes it look as if there was never any proper
testing and there is no real interest in proper testing. After all
that would involve cooperation and team work.

Want concrete evidence? I actually did report problems to Jes in
private emails, AS REQUESTED, in dmesg before I started tests and
posting patches. In the emalI stated I was willing to test drivers
with printk messages.  I did not even get the courtesy of a reply.

Want even more concrete evidence? Jes has some very strange comments
in his tree for his current last commit
f958b1e0806c045830d78c4287fbcddf9e5fd9d0

   " This uncovered a huge bug where the old code would use struct
    ieee80211_rate.flags to test for rate parameters, which is always
    zero, instead of the flags value from struct ieee80211_tx_rate.

    "Time to find a brown paper bag :("

John Heenan


>> Along with 'Fix for bogus data used to determine macpower',
>> wpa_supplicant now reliably and successfully authenticates.
>
>
> I'm not sure this paragraph belongs in the permanent commit record.
>
>> For rtl8xxxu-devel branch of
>> git.kernel.org/pub/scm/linux/kernel/git/jes/linux.git
>
>
> I know this line does not belong. If you want to include information like
> this, include it after a line containing "---". Those lines will be
> available to reviewers and maintainers, but will be stripped before it ge=
ts
> included in the code base.
>
>
>> Signed-off-by: John Heenan <john-AMlJbUfTsso@public.gmane.org>
>> ---
>>  drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 9 +++++----
>>  1 file changed, 5 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> index 04141e5..f25b4df 100644
>> --- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> +++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
>> @@ -5779,6 +5779,11 @@ static int rtl8xxxu_start(struct ieee80211_hw *hw=
)
>>
>>         ret =3D 0;
>>
>> +       ret =3D rtl8xxxu_init_device(hw);
>> +       if (ret)
>> +               goto error_out;
>> +
>> +
>>         init_usb_anchor(&priv->rx_anchor);
>>         init_usb_anchor(&priv->tx_anchor);
>>         init_usb_anchor(&priv->int_anchor);
>> @@ -6080,10 +6085,6 @@ static int rtl8xxxu_probe(struct usb_interface
>> *interface,
>>                 goto exit;
>>         }
>>
>> -       ret =3D rtl8xxxu_init_device(hw);
>> -       if (ret)
>> -               goto exit;
>> -
>>         hw->wiphy->max_scan_ssids =3D 1;
>>         hw->wiphy->max_scan_ie_len =3D IEEE80211_MAX_DATA_LEN;
>>         hw->wiphy->interface_modes =3D BIT(NL80211_IFTYPE_STATION);
>>
>
> I will let Jes comment on any side effects of this code change.
>
> Larry
>
> --
> If I was stranded on an island and the only way to get off
> the island was to make a pretty UI, I=E2=80=99d die there.
>
> Linus Torvalds
