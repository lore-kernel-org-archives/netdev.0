From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: Re: [PATCH] net: bluetooth: hci_core.c: Cleaning up uninitialized variables
Date: Sun, 1 Jun 2014 17:41:12 +0200
Message-ID: <CAFo99gZVJ3D-f_j8C4zYBod4yaLveq8X5__URyTuOAKcffN-Cg@mail.gmail.com>
References: <1401631076-20818-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<AB19A214-D495-44EE-87E0-45332F156767@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth <linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AB19A214-D495-44EE-87E0-45332F156767-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Marcel!


Sorry sorry!! This is obviously not necessary!

This is code that was left when I tried to split up my original big patch.

This was part of code trying to solve a possible divided by 0.


    int q = 0;

...

    if (num)
        q = cnt / num;
    *quote = q ? q : 1;


But I'm not sure if it can happen in reality...
Guessing it will be caught by in that case by:

    if (!chan)
        return NULL;



I had actually not planned to submit this divided by 0 patch at all :-/


Best regards
Rickard Strandqvist


2014-06-01 16:24 GMT+02:00 Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>:
> Hi Rickard,
>
>> There is a risk that the variable will be used without being initialized.
>>
>> This was largely found by using a static code analysis program called cppcheck.
>>
>> Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
>> ---
>> net/bluetooth/hci_core.c |    2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
>> index 1c6ffaa..1d93d2f 100644
>> --- a/net/bluetooth/hci_core.c
>> +++ b/net/bluetooth/hci_core.c
>> @@ -4603,7 +4603,7 @@ static struct hci_chan *hci_chan_sent(struct hci_dev *hdev, __u8 type,
>>       struct hci_chan *chan = NULL;
>>       unsigned int num = 0, min = ~0, cur_prio = 0;
>>       struct hci_conn *conn;
>> -     int cnt, q, conn_num = 0;
>> +     int cnt, q = 0, conn_num = 0;
>
> I have no idea on how the variable will be used without being initialized. Have you actually looked through that function. The only thing we do with q is assign it and then use it. That is it.
>
> Regards
>
> Marcel
>
