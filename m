From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [drivers] use msleep() instead of schedule_timeout() (from Nishanth Aravamudan <nacc@us.ibm.com>)
Date: Thu, 23 Sep 2004 12:26:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409231626.i8NGQ44f014489@ginger.cmf.nrl.navy.mil>
References: <nacc@us.ibm.com>
Cc: netdev@oss.sgi.com, davem@redhat.com, kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: Message from Nishanth Aravamudan <nacc@us.ibm.com>
   of "Thu, 23 Sep 2004 09:07:10 PDT." <20040923160710.GB1699@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

oops. sorry about that.  dave, please apply the following patch.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 12:24:28-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [lanai] get sleep interval right
# 
# drivers/atm/lanai.c
#   2004/09/23 12:24:12-04:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [lanai] get sleep interval right
# 
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2004-09-23 12:25:36 -04:00
+++ b/drivers/atm/lanai.c	2004-09-23 12:25:36 -04:00
@@ -813,7 +813,7 @@
 			DPRINTK("read, write = %d, %d\n", read, write);
 			break;
 		}
-		msleep(4);
+		msleep(40);
 	}
 	/* 15.2.2 - clear out all tx registers */
 	cardvcc_write(lvcc, 0, vcc_txreadptr);

In message <20040923160710.GB1699@us.ibm.com>,Nishanth Aravamudan writes:
>On Tue, Sep 21, 2004 at 04:29:19PM -0400, chas williams (contractor) wrote:
>
><snip>
>> diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
>> --- a/drivers/atm/lanai.c	2004-09-21 12:48:17 -04:00
>> +++ b/drivers/atm/lanai.c	2004-09-21 12:48:17 -04:00
>> @@ -813,7 +813,7 @@
>>  			DPRINTK("read, write = %d, %d\n", read, write);
>>  			break;
>>  		}
>> -		schedule_timeout(HZ / 25);
>> +		msleep(4);
>
>Somehow this got changed for msleep(40); to msleep(4); !! :) The patch I
>sent on 15 September had msleep(40); in it, at least. If you could make
>the change in your bk, that would be great!
>
>-Nish
>
