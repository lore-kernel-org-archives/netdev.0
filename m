From: varun <varun@rocsys.com>
Subject: iptables doubt
Date: Wed, 26 Apr 2006 12:39:22 +0530
Message-ID: <444F1CA2.4030904@rocsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [202.125.80.81] ([202.125.80.81]:65411 "EHLO rocsys.com")
	by vger.kernel.org with ESMTP id S1750896AbWDZHB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 03:01:56 -0400
Received: from rocsys.com (localhost [127.0.0.1] (may be forged))
	by rocsys.com (8.12.10/8.12.10) with ESMTP id k3QHkMFt027197
	for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 00:22:57 +0530
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

              Ive been trying to understand iptables kernel code and 
basically how it functions. In doing so i have a few questions.
              In the file ip_tables.c there is call do_replace() which 
is used as the start point entry from sockopt.
               That is this gets called everytime a user entrers 
policies from user. Here that data is given to me in the form of
                void __user *user.
                 This iam copying to kernel space and dereferencing into 
ipt_replace and so on. Am i right?
                  The first question is user seems to send a size as 860 
when trying to add the first policy. Does that mean that user is 
maintaining the offset of the policies added?
                    tmp.size shows as 768 which is (4 default policies x 
sizeof(struct ipt_standard)) + sizeof(struct ipt_error)
                    Am i correct in understanding? If so why should user 
space kernel policy offset?
                         Next thing is i added one extra field (int 
num)in the struct ipt_entry_target . This is added after the  unsigned 
char data[0] field.
struct ipt_entry_target
{
       union {
               struct {
                       u_int16_t target_size;

                       /* Used by userspace */
                       char name[IPT_FUNCTION_MAXNAMELEN-1];

                       u_int8_t revision;
               } user;
               struct {
                       u_int16_t target_size;

                       /* Used inside the kernel */
                       struct ipt_target *target;
               } kernel;

               /* Total length */
               u_int16_t target_size;
       } u;

       unsigned char data[0];
       unsigned int uniqueId;  /*I added this*/
};

    Iam using this field to give a global id from my kernel for every 
policy added excluding the default ones added by kernel. So if someone 
calls for iptables -F or iptables -t filter -D .... then this number 
should not be assigned to the structure.
   I want to know where is the correct place to add this value to 
structure without effecting the functionality.

 Iam also aware that making this change in structure will result in 
segmentation fault un userspace. Ill handel it seperately.
 Can this be done? Please help me in this regard.

 How can i know from the kernel structures if the policy is for -A or -D 
or -F ?
Varun
