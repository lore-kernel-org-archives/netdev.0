From: Michael D <michael.j.dilmore@gmail.com>
Subject: Re: [PATCH] Convert BUG_ON to WARN_ON in bond_options.c
Date: Wed, 21 Jun 2017 22:35:56 +0100
Message-ID: <CALRmy5sYL_gJsiLzQQn-2FbWowi=Bj4DkYdcOdrOHeSs4jQ3Xg@mail.gmail.com>
References: <1498068137-3550-1-git-send-email-michael.j.dilmore@gmail.com> <21644.1498070000@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Joe Perches <joe@perches.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21644.1498070000@famine>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

How do we actually stop a null pointer being dereferenced here? Other
examples I've seen check for null and then immediately return the
function with an error code so that it cannot be referenced again.
Something like:

if (WARN_ON(!new_active)
      return 1

This behaviour should be OK for this function, as if active_slave is
null, a new active slave obviously cannot be set. Or is there

On 21 June 2017 at 19:33, Jay Vosburgh <jay.vosburgh@canonical.com> wrote:
> Michael J Dilmore <michael.j.dilmore@gmail.com> wrote:
>
>>The function below contains a BUG_ON where no active slave is detected. The patch
>>converts this to a WARN_ON to avoid crashing the kernel.
>>
>>Signed-off-by: Michael J Dilmore <michael.j.dilmore@gmail.com>
>>---
>> drivers/net/bonding/bond_options.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>>diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
>>index 1bcbb89..c4b4791 100644
>>--- a/drivers/net/bonding/bond_options.c
>>+++ b/drivers/net/bonding/bond_options.c
>>@@ -778,7 +778,7 @@ static int bond_option_active_slave_set(struct bonding *bond,
>>               struct slave *old_active = rtnl_dereference(bond->curr_active_slave);
>>               struct slave *new_active = bond_slave_get_rtnl(slave_dev);
>>
>>-              BUG_ON(!new_active);
>>+              WARN_ON(!new_active);
>
>         This is a reasonable idea in principle, but will require
> additional changes to prevent dereferencing new_active if it is NULL
> (which would happen just below this point in the code).
>
>         -J
>
>>               if (new_active == old_active) {
>>                       /* do nothing */
>>--
>>2.7.4
>>
>
> ---
>         -Jay Vosburgh, jay.vosburgh@canonical.com
