From: Patrick McHardy <kaber@trash.net>
Subject: Re: A bug in the Kernel?
Date: Sun, 27 Feb 2005 17:26:36 +0100
Message-ID: <4221F4BC.1080409@trash.net>
References: <1125.80.249.146.137.1109520029.squirrel@mx.imec.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: itkes@fat.imec.msu.ru
In-Reply-To: <1125.80.249.146.137.1109520029.squirrel@mx.imec.msu.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

itkes@fat.imec.msu.ru wrote:
> Let us suppose the application to request the routing tabled dump. I heve
> found that in some conditions, this application may not receive some
> unchanged routes, if some other routes was deleted.

Could you describe this condition in more detail ? In your patch you
change the type of "args" to void *, which results in a bigger patch
and it shouldn't be done anyway. If you need to store a pointer simply
cast it to long. Please send a plain (not gzipped) patch without this
change and without the EXTRAVERSION change.

> P.S. After I have finished the patch, I found another bug in the Routing
> Tables Dump. In function fn_hash_dump_bucket in fib_hash.c there is a
> construction:
> if (i<s_i)
> 	continue;
> ...
> i++;
> If the first "if" is true in first moment, "i" will never be increased and
> some routes will be lost. My patch fixes this bug, too.

Good catch, this bug was introduced when switching to
hlist_for_each_entry().

-	for (i=0; f; i++, f=f->fn_next) {
-		if (i < s_i) continue;
+	i = 0;
+	hlist_for_each_entry(f, node, head, fn_hash) {
+		struct fib_alias *fa;
+
+		list_for_each_entry(fa, &f->fn_alias, fa_list) {
+			if (i < s_i)
+				continue;

Regards
Patrick
