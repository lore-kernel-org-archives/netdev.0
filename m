From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC] string matching based packet classification/filtering
Date: Thu, 17 Feb 2005 02:00:57 +0100
Message-ID: <4213ECC9.30502@eurodev.net>
References: <20050215203211.GL31837@postel.suug.ch>
	<42126C9B.5060406@eurodev.net>
	<20050216223038.GQ31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Harald Welte <laforge@gnumonks.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050216223038.GQ31837@postel.suug.ch>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>>Actually I wanted to contact Harald after this friday, once I'm done 
>>with my exams. I'd like to merge my work with his libqsearch hackings 
>>that were about to be finished.
>>    
>>
>
>Thinking about it, we can use the architecture to implement a regular
>expression match. The pattern would consist of an array of tokens
>in the form of:
>
>struct regexp_token
>{
>	__u8 type;
>	__u8 recur;
>	__u8 value;
>	__u8 unused;
>};
>  
>

Yes, this is a good idea. This could be useful to match things like 
interrogation marks or asterisks that are usually used as wildcard.

>where type would be
>  - specific character (must match `value')
>  - wildcard
>  - digit
>  - xdigit
>  - alpha ...
>
>and recur
> - 1
> - 0..1
> - 0..n
> - 1..0
>
>The matching algorithm would parse the array as a finite automation
>eating up byte by byte in the text.
>

Looks good but Boyer-Moore algorithm doesn't need this at all. BM 
doesn't support wildcards like '*' because of the shiftings that it uses 
to look for matches. This issue together with memory consumption are two 
limitations that we have to live with if we want to use BM. Anyway I 
think it's worth it because we can perform search in O(n/m).

--
Pablo
