From: Zilvinas Valinskas <zilvinas@gemtek.lt>
Subject: Re: Crypto tests via tcrypt.o modules failes
Date: Fri, 17 Sep 2004 10:49:25 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095407364.4174.6.camel@swoop.gemtek.lt>
References: <Xine.LNX.4.44.0409161524190.4676-100000@thoron.boston.redhat.com>
Reply-To: zilvinas@gemtek.lt
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0409161524190.4676-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-16 at 22:25, James Morris wrote:
> On Thu, 16 Sep 2004, Zilvinas Valinskas wrote:
> 
> > Details are here,http://www.gemtek.lt/~zilvinas/crypto/tcrypt-tests
> 
> AES is failing, but it has proven to be endian safe on other 
> architectures.
> 
> 
> Where does the 'fig' come from in:
> 
> <4>decrypt: fig 
that's my printk ... here goes diff :

--- aes.c       (revision 1164)
+++ aes.c       (working copy)
@@ -344,11 +344,22 @@
        u32 b0[4], b1[4];
        const u32 *kp = E_KEY + 4;
 
+       int i;
+
+       printk("encrypt: fig\n");
+
+       printk("encrypting block: ");
+       for (i=0; i<16; i++)
+               printk("%02X ", in[i]);
+       printk("\n");
+
        b0[0] = u32_in (in) ^ E_KEY[0];
        b0[1] = u32_in (in + 4) ^ E_KEY[1];
        b0[2] = u32_in (in + 8) ^ E_KEY[2];
        b0[3] = u32_in (in + 12) ^ E_KEY[3];
 
+
        if (ctx->key_length > 24) {
                f_nround (b1, b0, kp);
                f_nround (b0, b1, kp);
@@ -397,12 +408,17 @@
        u32 b0[4], b1[4];
        const int key_len = ctx->key_length;
        const u32 *kp = D_KEY + key_len + 20;
+       int i;
 
+       printk("decrypt: fig\n");
+
        b0[0] = u32_in (in) ^ E_KEY[key_len + 24];
        b0[1] = u32_in (in + 4) ^ E_KEY[key_len + 25];
        b0[2] = u32_in (in + 8) ^ E_KEY[key_len + 26];
        b0[3] = u32_in (in + 12) ^ E_KEY[key_len + 27];
 
+
        if (key_len > 24) {
                i_nround (b1, b0, kp);
                i_nround (b0, b1, kp);
@@ -428,6 +444,11 @@
        u32_out (out + 4, b0[1]);
        u32_out (out + 8, b0[2]);
        u32_out (out + 12, b0[3]);
+
+       printk("decrypted block: ");
+       for (i=0; i<16; i++)
+               printk("%02X ", out[i]);
+       printk("\n");

I've tried to check/make sure - when two boards Xscale <-> Xscale 
encrypts and decrypts data the same. Although it matches - content
print exactly the same - ping gets no echo-reply ... :( No clue where
to start looking. 
  
> 
> Can you try a completely unpatched kernel?
> 
> 
> - James
