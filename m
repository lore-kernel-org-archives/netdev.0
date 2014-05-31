From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH 2/11] cw1200: Remove useless return variables
Date: Sat, 31 May 2014 13:14:29 -0300
Message-ID: <CA+MoWDopnSqszCNTghH-5wrhzR+C7Bof9NoSGVGg9AhH_kZCVg@mail.gmail.com>
References: <1401542051-3174-2-git-send-email-peter.senna@gmail.com>
	<5389F2A0.1000903@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Solomon Peachy <pizza@shaftnet.org>,
	kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: walter harms <wharms@bfs.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5389F2A0.1000903@bfs.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 31, 2014 at 12:17 PM, walter harms <wharms@bfs.de> wrote:
>
>
> Am 31.05.2014 15:14, schrieb Peter Senna Tschudin:
>> This patch remove variables that are initialized with a constant,
>> are never updated, and are only used as parameter of return.
>> Return the constant instead of using a variable.
>>
>> Verified by compilation only.
>>
>> The coccinelle script that find and fixes this issue is:
>> // <smpl>
>> @@
>> type T;
>> constant C;
>> identifier ret;
>> @@
>> - T ret = C;
>> ... when != ret
>>     when strict
>> return
>> - ret
>> + C
>> ;
>> // </smpl>
>>
>> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
>>
>> ---
>>  drivers/net/wireless/cw1200/sta.c |   19 +------------------
>>  1 file changed, 1 insertion(+), 18 deletions(-)
>>
>> diff --git a/drivers/net/wireless/cw1200/sta.c b/drivers/net/wireless/cw1200/sta.c
>> index cd0cad7..622370c 100644
>> --- a/drivers/net/wireless/cw1200/sta.c
>> +++ b/drivers/net/wireless/cw1200/sta.c
>> @@ -2289,24 +2289,7 @@ static int cw1200_upload_null(struct cw1200_common *priv)
>>
>>  static int cw1200_upload_qosnull(struct cw1200_common *priv)
>>  {
>> -     int ret = 0;
>> -     /* TODO:  This needs to be implemented
>> -
>> -     struct wsm_template_frame frame = {
>> -             .frame_type = WSM_FRAME_TYPE_QOS_NULL,
>> -             .rate = 0xFF,
>> -     };
>> -
>> -     frame.skb = ieee80211_qosnullfunc_get(priv->hw, priv->vif);
>> -     if (!frame.skb)
>> -             return -ENOMEM;
>> -
>> -     ret = wsm_set_template_frame(priv, &frame);
>> -
>> -     dev_kfree_skb(frame.skb);
>> -
>> -     */
>> -     return ret;
>> +     return 0;
>>  }
>>
>>  static int cw1200_enable_beaconing(struct cw1200_common *priv,
>
>
> are you sure you want to remove the entire function ?
Removing the comments was my fault. Sent V2 keeping the comments.

>
> re,
>  wh
>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>



-- 
Peter
