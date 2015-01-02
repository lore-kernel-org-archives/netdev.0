From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] drivers:net:wireless: Add proper locking for the
 function, b43_op_beacon_set_tim in main.c
Date: Fri, 2 Jan 2015 12:19:12 +0100
Message-ID: <CACna6rxP5dB7ng5pf1jeJL7TTOq4xPC9B=wmrX+yeYK-hfF5uw@mail.gmail.com>
References: <1420184041-6788-1-git-send-email-xerofoify@gmail.com>
	<20150102102727.3918a684@wiggum>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicholas Krause <xerofoify@gmail.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Network Development <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	b43-dev <b43-dev@lists.infradead.org>,
	Kalle Valo <kvalo@codeaurora.org>
To: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150102102727.3918a684@wiggum>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2 January 2015 at 10:27, Michael B=C3=BCsch <m@bues.ch> wrote:
> On Fri,  2 Jan 2015 02:34:01 -0500
> Nicholas Krause <xerofoify@gmail.com> wrote:
>
>> This adds proper locking for the function, b43_op_beacon_set_tim in =
main.c by using the mutex lock
>> in the structure pointer wl, as embedded into this pointer as a mute=
x in order to protect against
>> multiple access to the pointer wl when updating the templates for th=
is pointer in the function,
>> b43_update_templates internally in the function, b43_op_beacon_set_t=
im.
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  drivers/net/wireless/b43/main.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/=
b43/main.c
>> index 47731cb..d568fc8 100644
>> --- a/drivers/net/wireless/b43/main.c
>> +++ b/drivers/net/wireless/b43/main.c
>> @@ -5094,8 +5094,9 @@ static int b43_op_beacon_set_tim(struct ieee80=
211_hw *hw,
>>  {
>>       struct b43_wl *wl =3D hw_to_b43_wl(hw);
>>
>> -     /* FIXME: add locking */
>> +     mutex_lock(&wl->mutex);
>>       b43_update_templates(wl);
>> +     mutex_unlock(&wl->mutex);
>>
>>       return 0;
>>  }
>
> Thanks for the patch.
>
> However, this does not work. We are in atomic context here.
> Please see the b43-dev mailing list archives for a recent thread abou=
t that.

Michael: guess who it was who sent the patch doing the same back in Nov=
ember.

Yes, the same troll.

--=20
Rafa=C5=82
