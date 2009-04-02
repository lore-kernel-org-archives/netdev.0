From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] x86: percpu_to_op() misses memory and flags clobbers
Date: Thu, 02 Apr 2009 07:12:30 -0700
Message-ID: <49D4C7CE.3060005@goop.org>
References: <20090402095217.GA30759@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, mingo@elte.hu, htejun@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	joe@perches.com, rusty@rustcorp.com.au
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:48580 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754382AbZDBOMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 10:12:34 -0400
In-Reply-To: <20090402095217.GA30759@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
>   
>> There's probably not a lot of value in this.  The Intel and AMD 
>> optimisation guides tend to deprecate inc/dec in favour of using 
>> add/sub, because the former can cause pipeline stalls due to its partial 
>> flags update.
>>     
>
> Is this still the case on the latest Intel CPUs?
>   

Yes:

    Assembly/Compiler Coding Rule 32. (M impact, H generality) INC and DEC
    instructions should be replaced with ADD or SUB instructions,
    because ADD and
    SUB overwrite all flags, whereas INC and DEC do not, therefore
    creating false
    dependencies on earlier instructions that set the flags.

    J
