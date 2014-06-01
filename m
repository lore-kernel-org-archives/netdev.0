From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH 4/11] via-ircc: Remove useless return variables
Date: Sun, 01 Jun 2014 13:42:30 +0200
Message-ID: <538B11A6.30306@bfs.de>
References: <1401542051-3174-4-git-send-email-peter.senna@gmail.com> <20140531203658.GO15585@mwanda>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Peter Senna Tschudin <peter.senna@gmail.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140531203658.GO15585@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Am 31.05.2014 22:36, schrieb Dan Carpenter:
> On Sat, May 31, 2014 at 10:14:04AM -0300, Peter Senna Tschudin wrote:
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
>>  drivers/net/irda/via-ircc.c |    9 +++------
>>  1 file changed, 3 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
>> index 2900af0..3fde116 100644
>> --- a/drivers/net/irda/via-ircc.c
>> +++ b/drivers/net/irda/via-ircc.c
>> @@ -509,11 +509,9 @@ static void via_hw_init(struct via_ircc_cb *self)
>>   *
>>   */
>>  static int via_ircc_read_dongle_id(int iobase)
>> -{
>> -	int dongle_id = 9;	/* Default to IBM */
>> -
>> +{/* Default to IBM */
> 
> Yuck.  And anyway, the comment should be on return line.  (And of course
> there should have been a #define IBM_DONGLE_ID 9, but that's probably
> something for another patch.
> 
>>  	IRDA_ERROR("via-ircc: dongle probing not supported, please specify dongle_id module parameter.\n");
>> -	return dongle_id;
>> +	return 9;


more over code and error msg do not fit,
it returns a default of 9 (what ever that means) it does not look like
an error. Sow the warning should be

via-ircc: dongle probing not supported, please specify dongle_id module parameter. settting dongle_id=9

re,
 wh


> So put the comment here.
> 
> 	return 9;  /* Everything is an IBM */
>>  }
>>  
> 
> regards,
> dan carpenter
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
