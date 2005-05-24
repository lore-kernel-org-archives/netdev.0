From: pravin b shelar <pravins@calsoftinc.com>
Subject: Re: [PATCH] : bug fix in multipath drr code.
Date: Tue, 24 May 2005 12:16:38 +0530
Message-ID: <4292CDCE.2090600@calsoftinc.com>
References: <4291CBFF.6080106@calsoftinc.com> <20050523232224.GA25349@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050523232224.GA25349@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Mon, May 23, 2005 at 05:56:39PM +0530, pravin wrote:
>  
>
>>        	/* if necessary and possible utilize the old alternative */
>>-	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 &&
>>-	    last_selection != NULL) {
>>-		result = last_selection;
>>-		*rp = result;
>>-		return;
>>+	if ((flp->flags & FLOWI_FLAG_MULTIPATHOLDROUTE) != 0 ) {
>>+		struct rtable *last_result = last_selection;
>>+		if(last_result != NULL &&
>>+		   multipath_comparekeys(&last_result->fl, flp)) {
>>+			*rp = last_result;
>>+			return;
>>+		}
>> 	}
>>    
>>
>
>You don't need all this code.  All you need to do is do
>result = last_selection before the if condition and then
>check result in the if condition instead of last_selection.
>
>The multipath_comparekeys isn't necessary either.
>
>  
>
In concurrent invocations of drr_select_route() last_selection will
change to different route.
So in that case we can not  use last_selection route on basis of
FLOWI_FLAG_MULTIPATHOLDROUTE flag only, since old
route might be totally different due another invocation of same function.
So, I think multipath_comparekeys is necessary.

Please correct me if I am wrong.

Regards,
Pravin.
