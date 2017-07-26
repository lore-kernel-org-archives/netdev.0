From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] netpoll: Fix device name check in netpoll_setup()
Date: Wed, 26 Jul 2017 13:52:59 -0700
Message-ID: <CAM_iQpV7ztXexDCAGPSiz6Yw7-Dib5AQcBcUXYzzUO+ZLZzRfw@mail.gmail.com>
References: <20170725183625.132345-1-mka@chromium.org> <CAD=FV=WiS3m=dr5VrhiOPiqVL4Rb53jfEambq79GtPffiYO-Pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Matthias Kaehlcke <mka@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Doug Anderson <dianders@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAD=FV=WiS3m=dr5VrhiOPiqVL4Rb53jfEambq79GtPffiYO-Pg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2017 at 11:44 AM, Doug Anderson <dianders@chromium.org> wrote:
> Hi,
>
> On Tue, Jul 25, 2017 at 11:36 AM, Matthias Kaehlcke <mka@chromium.org> wrote:
>> Apparently netpoll_setup() assumes that netpoll.dev_name is a pointer
>> when checking if the device name is set:
>>
>> if (np->dev_name) {
>>   ...
>>
>> However the field is a character array, therefore the condition always
>> yields true. Check instead whether the first byte of the array has a
>> non-zero value.
>>
>> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
>> ---
>>  net/core/netpoll.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
>> index 8357f164c660..912731bed7b7 100644
>> --- a/net/core/netpoll.c
>> +++ b/net/core/netpoll.c
>> @@ -666,7 +666,7 @@ int netpoll_setup(struct netpoll *np)
>>         int err;
>>
>>         rtnl_lock();
>> -       if (np->dev_name) {
>> +       if (np->dev_name[0]) {
>>                 struct net *net = current->nsproxy->net_ns;
>>                 ndev = __dev_get_by_name(net, np->dev_name);
>>         }
>
> It's really up to the maintainer of the code, but my first instinct
> here would be to instead remove the "if" test unless we really expect
> dev->dev_name to be blank in lots of cases.  It will slightly slow
> down the error case but should avoid an "if" test in the non-error
> case.  By definition it should be safe since currently the "if" test
> should always evaluate to true.
>

netconsole could set this dev_name to empty via configfs,
so this patch is correct.
