From: arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [v4] Fix to avoid IS_ERR_VALUE and IS_ERR abuses on 64bit systems.
Date: Tue, 2 Aug 2016 21:04:38 +0530
Message-ID: <57A0BD8E.9050305@gmail.com>
References: <1469963924-8800-1-git-send-email-arvind.yadav.cs@gmail.com>
 <1956647.cOmaJREgOE@wuerfel>
 <DB5PR0401MB19280ACA87C7F5EE2822D5FB91040@DB5PR0401MB1928.eurprd04.prod.outlook.com>
 <2484583.95xFmO7xir@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1941726227298117907=="
Cc: "qiang.zhao@freescale.com" <qiang.zhao@freescale.com>,
 "viresh.kumar@linaro.org" <viresh.kumar@linaro.org>,
 "zajec5@gmail.com" <zajec5@gmail.com>,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 Scott Wood <scott.wood@nxp.com>,
 "David.Laight@aculab.com" <David.Laight@aculab.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "scottwood@freescale.com" <scottwood@freescale.com>,
 "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "linux@roeck-us.net" <linux@roeck-us.net>
To: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <2484583.95xFmO7xir@wuerfel>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============1941726227298117907==
Content-Type: multipart/alternative;
 boundary="------------030904010008080602080808"

This is a multi-part message in MIME format.
--------------030904010008080602080808
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit



On Tuesday 02 August 2016 01:15 PM, Arnd Bergmann wrote:
> On Monday, August 1, 2016 4:55:43 PM CEST Scott Wood wrote:
>> On 08/01/2016 02:02 AM, Arnd Bergmann wrote:
>>>> diff --git a/include/linux/err.h b/include/linux/err.h
>>>> index 1e35588..c2a2789 100644
>>>> --- a/include/linux/err.h
>>>> +++ b/include/linux/err.h
>>>> @@ -18,7 +18,17 @@
>>>>   
>>>>   #ifndef __ASSEMBLY__
>>>>   
>>>> -#define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) >= (unsigned long)-MAX_ERRNO)
>>>> +#define IS_ERR_VALUE(x) unlikely(is_error_check(x))
>>>> +
>>>> +static inline int is_error_check(unsigned long error)
>>> Please leave the existing macro alone. I think you were looking for
>>> something specific to the return code of qe_muram_alloc() function,
>>> so please add a helper in that subsystem if you need it, not in
>>> the generic header files.
>> qe_muram_alloc (a.k.a. cpm_muram_alloc) returns unsigned long.  The
>> problem is certain callers that store the return value in a u32.  Why
>> not just fix those callers to store it in unsigned long (at least until
>> error checking is done)?
>>
> Yes, that would also address another problem with code like
>
>           kfree((void *)ugeth->tx_bd_ring_offset[i]);
>
> which is not 64-bit safe when tx_bd_ring_offset is a 32-bit value
> that also holds the return value of qe_muram_alloc.
>
> 	Arnd
Yes, we will fix caller. Caller api is not safe on 64bit.
Even qe_muram_addr(a.k.a. cpm_muram_addr )passing value unsigned int,
but it should be unsigned long.



--------------030904010008080602080808
Content-Type: text/html; charset=windows-1252
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=windows-1252"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <br>
    <br>
    <div class="moz-cite-prefix">On Tuesday 02 August 2016 01:15 PM,
      Arnd Bergmann wrote:<br>
    </div>
    <blockquote cite="mid:2484583.95xFmO7xir@wuerfel" type="cite">
      <pre wrap="">On Monday, August 1, 2016 4:55:43 PM CEST Scott Wood wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">On 08/01/2016 02:02 AM, Arnd Bergmann wrote:
</pre>
      </blockquote>
      <pre wrap="">
</pre>
      <blockquote type="cite">
        <blockquote type="cite">
          <blockquote type="cite">
            <pre wrap="">diff --git a/include/linux/err.h b/include/linux/err.h
index 1e35588..c2a2789 100644
--- a/include/linux/err.h
+++ b/include/linux/err.h
@@ -18,7 +18,17 @@
 
 #ifndef __ASSEMBLY__
 
-#define IS_ERR_VALUE(x) unlikely((unsigned long)(void *)(x) &gt;= (unsigned long)-MAX_ERRNO)
+#define IS_ERR_VALUE(x) unlikely(is_error_check(x))
+
+static inline int is_error_check(unsigned long error)
</pre>
          </blockquote>
          <pre wrap="">
Please leave the existing macro alone. I think you were looking for
something specific to the return code of qe_muram_alloc() function,
so please add a helper in that subsystem if you need it, not in
the generic header files.
</pre>
        </blockquote>
        <pre wrap="">
qe_muram_alloc (a.k.a. cpm_muram_alloc) returns unsigned long.  The
problem is certain callers that store the return value in a u32.  Why
not just fix those callers to store it in unsigned long (at least until
error checking is done)?

</pre>
      </blockquote>
      <pre wrap="">
Yes, that would also address another problem with code like

         kfree((void *)ugeth-&gt;tx_bd_ring_offset[i]);

which is not 64-bit safe when tx_bd_ring_offset is a 32-bit value
that also holds the return value of qe_muram_alloc.

	Arnd</pre>
    </blockquote>
    Yes, we will fix caller. Caller api is not safe on 64bit. <br>
    Even qe_muram_addr(a.k.a. cpm_muram_addr )passing value unsigned
    int,<br>
    but it should be unsigned long.<br>
    <meta http-equiv="content-type" content="text/html;
      charset=windows-1252">
    <meta http-equiv="content-type" content="text/html;
      charset=windows-1252">
    <br>
    <br>
  </body>
</html>

--------------030904010008080602080808--

--===============1941726227298117907==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============1941726227298117907==--
